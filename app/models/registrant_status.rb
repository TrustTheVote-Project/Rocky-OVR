class RegistrantStatus < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :registrant
  belongs_to :admin
  belongs_to :geo_state
  
  serialize :state_data, Hash
  
  attr_protected :id, :created_at, :updated_at
  
  def self.get_columns(state)
    case state.abbreviation
    when "PA"
      return {id_column: "Application_ID", date_column: "Application_Date", status_column: "Status", status_details_column: "Status_Reason"}
    end
  end
  
  def self.state_registrant_id_column(state)
    case state.abbreviation
    when "PA"
      return :pa_transaction_id
    end
  end
  
  def self.get_state_registrants(state) 
    case state.abbreviation
    when "PA"
      return StateRegistrants::PARegistrant.includes(:registrant)
    end
    return nil
  end
  
  def self.state_ovr_id_finder(state, state_id)
    case state
    when GeoState["PA"]
      "%pa_transaction_id: '#{state_id}'%"
    end
  end
  
  def self.s3connection
    @@s3connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
  end
  
  def self.bucket_name
    @@bucket_name ||= "rocky-reports#{Rails.env.production? ? '' : "-#{Rails.env}"}"
  end
  
  def self.import_ovr_status!(csv, state, admin_user)
    # Store csv file for importing
    key = nil
    File.open(csv) do |f|
      path  = f.path
      file_name = path.split('/').last
      directory = s3connection.directories.get(bucket_name)
      key = "admin/status-uploads/#{Time.now}/#{file_name.gsub(/^\//,'')}"
      file = directory.files.create(
        :key    => key,
        :body   => f.read,
        :content_type => "text/csv",
        :encryption => 'AES256', #Make sure its encrypted on their own hard drives
        :public => false
      )       
    end
    
    self.delay.run_import!(key, state.id, admin_user.id)
  end
    
  def self.run_import!(key, state_id, admin_user_id)
    directory = s3connection.directories.get(bucket_name)
    file = directory.files.get(key)
    return if !file
    csv = file.body
    
    state = GeoState.find(state_id)
    admin_user = Admin.find(admin_user_id)
    
    # First, read the registrants into a list
    reg_statuses = {}
    max_date = Date.parse("2000-01-01")
    min_date = Date.parse(1.day.from_now.to_s)
    cols = self.get_columns(state)

    imports = CSV.parse(csv.gsub(/\r\n/,"\n"), {:headers=>true}) #,  :encoding => 'windows-1251:utf-8'
    valid_row_count = 0
    imports.each do |row|
      next if row.to_s.strip.blank?
      state_transaction_id = row[cols[:id_column]]
      state_application_date = row[cols[:date_column]]
      next if state_transaction_id.blank?
      next if state_application_date.blank?
      
      if state_application_date =~ /\/\d{4}$/
        state_application_date = Date.strptime(state_application_date, "%m/%d/%Y")
      else
        state_application_date = Date.strptime(state_application_date, "%m/%d/%y")
      end
      state_status = row[cols[:status_column]]
      state_status_details = row[cols[:status_details_column]]
      reg_statuses[state_transaction_id] = {
        state_transaction_id: state_transaction_id,
        state_application_date: state_application_date,
        state_status: state_status,
        state_status_details: state_status_details,
        geo_state_id: state.id,
        state_data: row.to_hash,
        admin_id: admin_user.id
      }

      if state_application_date < min_date
        min_date = state_application_date
      end
      if state_application_date > max_date
        max_date = state_application_date
      end
      valid_row_count += 1
    end
    
    reg_statuses_results = {}
    
    potential_registrants = Registrant.where(home_state_id: state.id).where("created_at >= ? and created_at <= ?", min_date - 14.days, max_date + 1.days).where("state_ovr_data IS NOT NULL and state_ovr_data != '--- {}\\n'")
    potential_state_registrants = self.get_state_registrants(state)
    potential_state_registrants_id_column = self.state_registrant_id_column(state)
    
    
    
    reg_statuses.each do |state_id, reg_data|
      # Find row in table?
      existing = RegistrantStatus.where(state_transaction_id: state_id, geo_state_id: reg_data[:geo_state_id]).first
      if (existing)
        existing.update_attributes(reg_data)
        reg_statuses_results[state_id] = "Updated status record"
      else
        # Find registrant
        regs = []
        if potential_state_registrants
          regs = potential_state_registrants.where(potential_state_registrants_id_column => state_id)
        end
        if !regs.any?
          regs = potential_registrants.where("state_ovr_data LIKE ?", state_ovr_id_finder(state, state_id))
        end
        if (regs.count > 1)
          reg_statuses_results[state_id] = "More than one registrant matched #{reg_data}"
        elsif regs.count == 0
          reg_statuses_results[state_id] = "No registrants matched #{reg_data}"
        else
          reg = regs.first
          reg_id = reg.is_a?(Registrant) ? reg.id : reg.registrant.id
          data = reg_data.merge({registrant_id: reg_id})
          RegistrantStatus.create!(data)
          reg_statuses_results[state_id] = "Created status record"          
        end
      end
    end
    notify_admin(build_message(valid_row_count, reg_statuses_results), admin_user)
  end
  
  def self.build_message(rc, status_results)
    str = []
    str << "#{rc} rows processed.\n\n"
    status_results.each do |k,v|
      if v.is_a?(Hash)
        str << "#{k}:"
        v.each do |k2,v2|
          str<< "    #{k2} => #{v2}"
        end
      else
        str << "#{k}: #{v}"        
      end
      str << "\n"
    end
    str.join("\n")
  end
  
  def self.notify_admin(results, user)
    email = user.email
    AdminMailer.import_results(results, email).deliver_now
  end
  
  
end
