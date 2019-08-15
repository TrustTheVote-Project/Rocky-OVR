class Report < ActiveRecord::Base
  GROMMET_SHIFT_REPORT="grommet_shift_report".freeze
  GROMMET_REGISTRANTS_REPORT="grommet_registrants_report".freeze
  REGISTRANTS_REPORT="registrants_report".freeze
  QUEUE_NAME = "reports".freeze
  THRESHOLD = 100
  Status = OpenStruct.new({
    queued: :queued,
    building: :building,
    merging: :merging,
    complete: :complete
  })

  belongs_to :partner
  serialize :data, Hash

  def self.run(report_id)
    begin
      r = Report.find(report_id)
    rescue
      puts "Couldn't find report"
    end
    r.run if r
  end
  
  def self.concatenate(report_id)
    r = Report.find(report_id)
    r.concatenate
  end
  
  def self.write_report_file(fn, contents)
    full_fn = Rails.root.join("tmp_reports", fn)
    FileUtils.mkdir_p(Rails.root.join("tmp_reports"))
    File.open(full_fn, "w+") do |f|
      f.write contents
    end
  end
  
  def self.read_report_file(fn)
    full_fn = Rails.root.join("tmp_reports", fn)
    FileUtils.mkdir_p(Rails.root.join("tmp_reports"))
    c = ""
    File.open(full_fn, "r") do |f|
      c = f.read
    end
    return c
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
  end
  
  def use_parts
    self.record_count > THRESHOLD
  end
  
  def generate_report
    csvstr = self.send("generate_#{report_type}",current_index)
    if use_parts
      fn = file_name(current_index)
      Report.write_report_file(fn, csvstr)
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
      Report.write_report_file(file_name, "#{csvheadstr}#{csvstr}")
      self.current_index = self.record_count
      self.status = Status.complete
      self.save!
    end
  end
  
  def concatenate
    # Get all the files 
    csvstr = CSV.generate do |csv|
      csv << csv_header
    end
    
    (0..(self.record_count / THRESHOLD)).each do |i|
      fn = file_name(i*THRESHOLD)
      csvstr += "#{Report.read_report_file(fn)}"
    end
    
    Report.write_report_file(file_name, csvstr)
    self.status = Status.complete
    self.save!
    
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
  
  def registrants_report_csv_header
    Registrant::CSV_HEADER
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
    conditions[0] = conditions[0].join(" AND ")
    return conditions
  end
  
  def registrants_report_selector
    @registrants_report_selector ||= partner.registrants.where(registrants_report_conditions)
  end
  
  def generate_registrants_report(start=0)
    distribute_reads(failover: false) do
      pa_registrants = {}
      StateRegistrants::PARegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_pa_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      va_registrants = {}
      StateRegistrants::VARegistrant.where(conditions).joins("LEFT OUTER JOIN registrants on registrants.uid=state_registrants_va_registrants.registrant_id").where('registrants.partner_id=?',self.partner_id).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      
      return CSV.generate do |csv|
        selector.includes([:home_state, :mailing_state, :partner, :registrant_status]).offset(start).limit(THRESHOLD).each do |reg|
          if reg.use_state_flow?
            sr  = nil
            case reg.home_state_abbrev
            when "PA"
              sr = pa_registrants[reg.uid] || StateRegistrants::PARegistrant.new
            when "VA"
              sr = va_registrants[reg.uid] || StateRegistrants::VARegistrant.new
            end
            reg.instance_variable_set(:@existing_state_registrant, sr)
          end
          csv << reg.to_csv_array
        end
      end
    end
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
  

  
  def grommet_shift_report_selector
    @grommet_shift_report_selector ||= partner.registrants.where(grommet_shift_report_conditions)
  end
  
  def generate_grommet_registrants_report(start=nil)
    self.data ||= {}
    reg_dups = self.data[:reg_dups] || {}
    
    distribute_reads(failover: false) do
      csv_string = CSV.generate do |csv|
        csv << Registrant::GROMMET_CSV_HEADER if start == nil
        regs = []
        registrants.where(conditions).includes( [:home_state, :mailing_state, :partner, :registrant_status]).find_each(:batch_size=>500) do |reg|
          if reg.is_grommet?
            key = "#{reg.first_name} #{reg.last_name} #{reg.home_address}"
            reg_dups[key] ||= 0
            reg_dups[key] += 1
            regs << [reg.to_grommet_csv_array, key].flatten
          end
        end
        regs.each do |r|
          key = r.pop
          if reg_dups[key] > 1
            r.insert(1, "true")
          else
            r.insert(1, "false")
          end
          csv << r
        end
      end
      
      self.data[:reg_dups] = reg_dups
      self.save
      return csv_string
    end
    
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
