class Report < ActiveRecord::Base
  include TimeStampHelper
  
  GROMMET_SHIFT_REPORT="grommet_shift_report".freeze
  CANVASSING_SHIFT_REPORT="canvassing_shift_report".freeze
  GROMMET_REGISTRANTS_REPORT="grommet_registrants_report".freeze
  REGISTRANTS_REPORT="registrants_report".freeze
  REGISTRANTS_REPORT_EXTENDED="registrants_report_extended".freeze
  ABR_REPORT = "abr_report".freeze
  LOOKUP_REPORT = "lookup_report".freeze
  ALERT_REQUEST_REPORT = "alert_request_report".freeze
  
  REPORT_TYPES = [
    GROMMET_SHIFT_REPORT,
    CANVASSING_SHIFT_REPORT,
    GROMMET_REGISTRANTS_REPORT,
    REGISTRANTS_REPORT,
    REGISTRANTS_REPORT_EXTENDED,
    ABR_REPORT,
    LOOKUP_REPORT,
    ALERT_REQUEST_REPORT
  ].freeze

  QUEUE_NAME = "reports".freeze
  THRESHOLD = 500

  include AlertRequestReportHelper
  
  
  SHIFT_REPORT_HEADER = [
    "Date",
    "Unique Shift ID",	
    "Canvasser Name",	
    "Event Zip code",
    "Event Location",	
    "Tablet number",
    "Registrations Collected",
    "Registrations Abandoned",	
    "Registrations Received",
    "# Opt-in to Partner email?",
    "# Opt-in to Partner sms/robocall?",
    "# Registrations w/DL",
    "Registrations w/DL %",
    "# Registrations w/SSN",	
    "Registrations w/SSN %",
    "Canvasser Clock IN (EST)",
    "Canvasser Clock OUT (EST)",
    "Total Shift Hours"    
  ]
  
  Status = OpenStruct.new({
    queued: :queued,
    building: :building,
    merging: :merging,
    complete: :complete,
    post_processing: :post_processing,
    failed: :failed
  })

  belongs_to :partner, optional: true
  has_many :report_data
  serialize :filters, Hash

  before_save :ensure_dates

  def ensure_dates
    self.start_date = 1.month.ago if self.start_date.blank? 
    self.end_date = 1.hour.ago if self.end_date.blank? 
  end

  def self.run(report_id)
    begin
      r = Report.find(report_id)
    rescue
      Rails.logger.error("Couldn't find report with id #{report_id}")
      return
    end
    r.run if r
  end

  def self.concatenate(report_id)
    r = Report.find(report_id)
    r.concatenate
  end
  
  def title
    case self.report_type
    when GROMMET_SHIFT_REPORT
      return "PA Shift Report"
    when GROMMET_REGISTRANTS_REPORT
      return "PA APP Registrants Report"
    when REGISTRANTS_REPORT
      return "Registrants Report"
    when REGISTRANTS_REPORT_EXTENDED
      return "Registrants Report Extended"
    when CANVASSING_SHIFT_REPORT
      return "Canvassing Shift Report"
    when ABR_REPORT
      return "Absentee Requests Report"
    when LOOKUP_REPORT
      return "Voter Status Lookup Report"
    when ALERT_REQUEST_REPORT
      return "Voter Pledge Report"
    end
  end
  
  def download_file_name
    [title, start_date ? start_date.strftime("%Y%m%d") : "through", end_date ? end_date.strftime("%Y%m%d") : created_at.strftime("%Y%m%d")].join("_").parameterize + ".csv"
  end
  
  def s3_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })    
  end
  
  def directory
    @directory ||= s3_connection.directories.get('rocky-report-objects')
    
  end
  
  def s3_key(fn)
    "#{Rails.env}/#{id}/#{fn}"
  end
  
  def write_report_file(fn, contents)
    directory.files.create(
      :key    => s3_key(fn),
      :body   => contents,
      :content_type => "text/csv",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => false
    )
  end
  
  def read
    read_report_file(file_name)
  end
  
  def read_report_file(fn)
    file = directory.files.get(s3_key(fn))
    return file.body
  end
  
  def file_name(count=nil)
    ([id, count].compact.join("_") + ".csv")
  end

  def queue!
    self.status = Status.queued
    self.save!
    Report.delay({
      queue: QUEUE_NAME
    }).run(self.id)
  end
  
  def run
    self.record_count ||= selector.count
    self.current_index ||= 0
    self.status = Status.building
    self.save!    
    # If count > threshold, build up in parts
    generate_report
  rescue Exception => e
    handle_error(e)
  end
  
  def handle_error(e)
    r = Report.find(self.id)
    r.status = Status.failed
    r.error = [e.message, e.backtrace].join("\n").to_s.force_encoding("UTF-8")
    r.save
  end
  
  def use_parts
    self.record_count > THRESHOLD && report_type != GROMMET_SHIFT_REPORT
  end
  
  def generate_report
    csvstr = self.send("generate_#{report_type}",current_index)
    if use_parts
      fn = file_name(current_index)
      self.write_report_file(fn, csvstr)
      self.current_index += THRESHOLD
      self.save
      if self.current_index < self.record_count
        Report.delay({
          queue: QUEUE_NAME
        }).run(self.id)
      else
        self.status = Status.merging
        self.current_index = self.record_count        
        Report.delay({
          queue: QUEUE_NAME
        }).concatenate(self.id)
        self.save!        
      end
    else
      csvheadstr = CSV.generate do |csv|
        csv << csv_header
      end
      self.write_report_file(file_name, "#{csvheadstr}#{csvstr}")
      self.current_index = self.record_count
      self.status = Status.complete
      self.save!
    end
  end
  
  def concatenate
    # Get all the files 
    csvstr = ""
    (0..((self.record_count-1) / THRESHOLD)).each do |i|
      fn = file_name(i*THRESHOLD)
      csvstr += "#{self.read_report_file(fn)}"
    end
    csvstr = post_process(csvstr)

    csvstr = CSV.generate do |csv|
      csv << csv_header
    end + csvstr

    
    self.write_report_file(file_name, csvstr)
    self.status = Status.complete
    self.save!
  rescue Exception => e
    handle_error(e)    
  end
  
  def post_process(csvstr)
    if self.respond_to?("post_process_#{report_type}")
      self.status = Status.post_processing
      self.save
      return self.send("post_process_#{report_type}", csvstr)
    else
      return csvstr
    end
  ensure
    self.report_data.destroy_all    
  end
  
  def selector
    self.send("#{report_type}_selector")
  end
  
  def conditions
    self.send("#{report_type}_conditions")
  end
  
  def csv_header
    self.send("#{report_type}_csv_header")
  end
  



  def canvassing_shift_report_csv_header
    CanvassingShift::CSV_HEADER
  end
  
  def canvassing_shift_report_conditions    
    conditions = [[]]
    if start_date
      conditions[0] << " canvassing_shifts.created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " canvassing_shifts.created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def canvassing_shift_report_selector
    @canvassing_shift_report_selector ||= partner.canvassing_shifts.where(canvassing_shift_report_conditions)
  end
    
  def generate_canvassing_shift_report(start=0, csv_method=:to_csv_array)
    distribute_reads(failover: false) do
      return CSV.generate do |csv|
        selector.includes(:registrants).order(:id).offset(start).limit(THRESHOLD).each do |cs|
          csv << cs.send(csv_method)
        end
      end
    end
  end
  
  
  


  def abr_report_csv_header
    Abr::CSV_HEADER
  end
  
  def abr_report_conditions    
    conditions = [[]]
    if start_date
      conditions[0] << " abrs.created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " abrs.created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def abr_report_selector
    @abr_report_selector ||= partner.abrs.where(abr_report_conditions)
  end
    
  def generate_abr_report(start=0, csv_method=:to_csv_array)
    distribute_reads(failover: false) do
      return CSV.generate do |csv|
        selector.order(:id).offset(start).limit(THRESHOLD).each do |abr|
          csv << abr.send(csv_method)
        end
      end
    end
  end



  def lookup_report_csv_header
    CatalistLookup::CSV_HEADER
  end
  
  def lookup_report_conditions    
    conditions = [[]]
    if start_date
      conditions[0] << " catalist_lookups.created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " catalist_lookups.created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def lookup_report_selector
    @lookup_report_selector ||= partner.catalist_lookups.where(lookup_report_conditions)
  end
    
  def generate_lookup_report(start=0, csv_method=:to_csv_array)
    distribute_reads(failover: false) do
      return CSV.generate do |csv|
        selector.includes(abrs_catalist_lookup: [:abr], catalist_lookups_registrant: [], state: []).order(:id).offset(start).limit(THRESHOLD).each do |lookup|
          csv << lookup.send(csv_method)
        end
      end
    end
  end





  
  def registrants_report_csv_header
    Registrant::CSV_HEADER
  end
  def registrants_report_extended_csv_header
    Registrant::CSV_HEADER_EXTENDED
  end
  
  def registrants_report_conditions    
    conditions = [[]]
    if start_date
      conditions[0] << " registrants.created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " registrants.created_at < ? "
      conditions << end_date + 1.day
    end
    if filters && filters[:email_address] && !filters[:email_address].blank?
      conditions[0] << " email_address = ? "
      conditions << filters[:email_address]
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def registrants_report_extended_conditions
    registrants_report_conditions
  end
  
  def registrants_report_selector
    if filters && filters[:home_state_id] || filters[:home_zip_code]
      if filters[:home_state_id]
        @registrants_report_selector ||= Registrant.where(home_state_id: filters[:home_state_id]).where(registrants_report_conditions)
      elsif filters[:home_zip_code]
        @registrants_report_selector ||= Registrant.where(home_zip_code: filters[:home_zip_code]).where(registrants_report_conditions)
      end
    else
      @registrants_report_selector ||= partner.registrants.where(registrants_report_conditions)
    end
    @registrants_report_selector.includes(:voter_signature)
  end
  
  def registrants_report_extended_selector
    @registrants_report_extended_selector ||= registrants_report_selector.includes(:pdf_delivery, {:canvassing_shift_registrant => :canvassing_shift})    
  end
  
  
  def generate_registrants_report(start=0, csv_method=:to_csv_array)
    distribute_reads(failover: false) do
      pa_registrants = {}
      StateRegistrants::PARegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_pa_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      va_registrants = {}
      StateRegistrants::VARegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_va_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      mi_registrants = {}
      StateRegistrants::MIRegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_mi_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| mi_registrants[sr.registrant_id] = sr}
      mn_registrants = {}
      StateRegistrants::MNRegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_mn_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| mn_registrants[sr.registrant_id] = sr}
      wa_registrants = {}
      StateRegistrants::WARegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_was_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| wa_registrants[sr.registrant_id] = sr}

      
      return CSV.generate do |csv|
        selector.includes([:home_state, :mailing_state, :partner, :registrant_status]).order(:id).offset(start).limit(THRESHOLD).each do |reg|
          if reg.use_state_flow?
            sr  = nil
            case reg.home_state_abbrev
            when "PA"
              sr = pa_registrants[reg.uid] || nil
            when "VA"
              sr = va_registrants[reg.uid] || nil
            when "MI"
              sr = mi_registrants[reg.uid] || nil
            when "MN"
              sr = mn_registrants[reg.uid] || nil
            when "WA"
              sr= wa_registrants[reg.uid] || nil
            end
            reg.instance_variable_set(:@existing_state_registrant, sr)
            reg.instance_variable_set(:@existing_state_registrant_fetched, true)
          end
          csv << reg.send(csv_method)
        end
      end
    end
  end
  
  def generate_registrants_report_extended(start=0)
    generate_registrants_report(start, :to_csv_extended_array)
  end
  
  def grommet_shift_report_conditions
    conditions = [[]]
    if start_date
      conditions[0] << " created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  

  
  def grommet_registrants_report_csv_header
    Registrant::GROMMET_CSV_HEADER
  end
  
  
  def grommet_shift_report_selector
    @grommet_shift_report_selector ||= partner.registrants.where(grommet_shift_report_conditions)
  end
  
  def grommet_shift_report_csv_header
    Report::SHIFT_REPORT_HEADER
  end
  
  def generate_grommet_shift_report(start=0)
    shift_ids = {}
    distribute_reads(failover: false) do
      selector.includes([:home_state, :mailing_state, :partner, :registrant_status]).find_in_batches(:batch_size=>THRESHOLD) do |batch|
        batch.each do |reg|
          shift_ids[reg.tracking_source] ||= {
            registrations: 0,
            email_opt_in: 0,
            sms_opt_in: 0,
            ssn_count: 0,
            dl_count: 0
          } #TrackingEvent.source_tracking_id
          shift_ids[reg.tracking_source][:registrations] += 1
          shift_ids[reg.tracking_source][:email_opt_in] += 1 if reg.partner_opt_in_email?
          shift_ids[reg.tracking_source][:sms_opt_in] += 1 if reg.partner_opt_in_sms?
          shift_ids[reg.tracking_source][:ssn_count] += 1 if reg.has_ssn?
          shift_ids[reg.tracking_source][:dl_count] += 1 if reg.has_state_license?
          # This is a one-shot report, so generate it here.
        end
        self.current_index += THRESHOLD
        self.save
      end
      clock_ins = TrackingEvent.where(source_tracking_id: shift_ids.keys, tracking_event_name: "pa_canvassing_clock_in")
      clock_outs = {}
      TrackingEvent.where(source_tracking_id: shift_ids.keys, tracking_event_name: "pa_canvassing_clock_out").each do |co|
        clock_outs[co.source_tracking_id] = co
      end
      csvstr = CSV.generate do |csv|
        clock_ins.sort{|a,b|( a.tracking_data["clock_in_datetime"] || "") <=> (b.tracking_data["clock_in_datetime"] || "")}.each do |ci|
          co = clock_outs[ci.source_tracking_id]
          tracking_source = ci.source_tracking_id
          counts = shift_ids[tracking_source]
          row = []
          row << eastern_time(ci.tracking_data["clock_in_datetime"])
          row << tracking_source
          row << ci.tracking_data["canvasser_name"]
          row << ci.partner_tracking_id
          row << ci.open_tracking_id
          row << ci.tracking_data["device_id"]
          row << (co ? co.tracking_data["completed_registrations"] : "")
          row << (co ? co.tracking_data["abandoned_registrations"] : "")
          row << counts[:registrations]
          row << counts[:email_opt_in]
          row << counts[:sms_opt_in]
          row << counts[:dl_count]
          row << '%.2f %%' % (100.0 * (counts[:dl_count].to_f / counts[:registrations].to_f).to_f)
          row << counts[:ssn_count]
          row << '%.2f %%' % (100.0 * (counts[:ssn_count].to_f / counts[:registrations].to_f).to_f)
          row << eastern_time(ci.tracking_data["clock_in_datetime"])
          if co
            row << eastern_time(co.tracking_data["clock_out_datetime"])
            begin
              shift_seconds = (Time.parse(co.tracking_data["clock_out_datetime"]) - Time.parse(ci.tracking_data["clock_in_datetime"])).to_f
              row << shift_seconds / 3600.0
            rescue
              row << ""
            end
          else
            row << ""
            row << ""
          end
          csv << row
        end
      end
      return csvstr
    end
  end
  
  def generate_grommet_registrants_report(start=0)
    distribute_reads(failover: false) do
      csv_string = CSV.generate do |csv|
        selector.includes( [:home_state, :mailing_state, :partner, :registrant_status]).order(:id).offset(start).limit(THRESHOLD).each do |reg|
          if reg.is_grommet?
            key = "#{reg.first_name} #{reg.last_name} #{reg.home_address}"
            rd = report_data.find_or_create_by(key: key, report_id: self.id)
            rd.i_value ||= 0
            rd.i_value += 1
            rd.save
            csv << ([reg.to_grommet_csv_array, key].flatten)
          end
        end
      end
      return csv_string
    end    
  end
  
  def post_process_grommet_registrants_report(csvstr)
    csv = CSV.new(csvstr)
    new_str = CSV.generate do |newcsv|
      csv.each do |row|
        key = row.pop
        rd = self.report_data.where(key: key).first
        if rd && rd.i_value && rd.i_value > 1
          row.insert(1, "true")
        else
          row.insert(1, "false")
        end
        newcsv << row
      end
    end
    return new_str
  end
  
  def grommet_registrants_report_conditions
    conditions = [[]]
    if start_date
      conditions[0] << " created_at >= ? "
      conditions << start_date
    end
    if end_date
      conditions[0] << " created_at < ? "
      conditions << end_date + 1.day
    end
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  def grommet_registrants_report_selector
    @grommet_registrants_report_selector ||= partner.registrants.where(grommet_registrants_report_conditions)
  end
  
end
