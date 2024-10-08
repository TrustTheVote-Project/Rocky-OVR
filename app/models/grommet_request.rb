class GrommetRequest < ActiveRecord::Base
  # attr_accessible :title, :body
  STATES = %w(PA MI)

  after_create :generate_request_hash
  
  serialize :request_params, Hash
  
  def generate_request_hash
    if STATES.include?(self.state)
      hash_key_method = "#{self.state.downcase}_hash_key"
      hash_key = self.send(hash_key_method)
      if hash_key
        self.request_hash = Digest::MD5.hexdigest(hash_key) 
        save(validate: false)
      end
    end
  end
    
  def pa_hash_key
    params = self.request_params.is_a?(Hash) || self.request_params.is_a?(ActionController::Parameters) ? self.request_params : YAML::load(self.request_params)
    params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
    params = params.with_indifferent_access
    if params["rocky_request"] && params["rocky_request"]["voter_records_request"]
      r = params["rocky_request"]["voter_records_request"]["voter_registration"]
      d = params["rocky_request"]["voter_records_request"]["generated_date"]
      return key = "#{d}-#{r}"      
    end
    return nil
  end

  def mi_hash_key
    params = self.request_params.is_a?(Hash) ? self.request_params : YAML::load(self.request_params)
    return "#{params["registration"]}"
  end
    
  def is_duplicate?
    self != self.class.where(request_hash: self.request_hash, state: self.state).order(:id).first
  end
  
  def has_duplicates?
    self.class.where(request_hash: self.request_hash, state: self.state).count > 1
  end
  
  def resubmit
    if STATES.include?(self.state)
      method_name = "#{self.state.downcase}_resubmit"
      self.send(method_name)
    end
  end

  # def mi_resubmit
    
  # end

  def pa_resubmit
    registrant = nil
    params = self.request_params.is_a?(Hash) || self.request_params.is_a?(ActionController::Parameters) ? self.request_params : YAML::load(self.request_params)
    if params.respond_to?(:to_unsafe_h)
      params = params.to_unsafe_h
    end
    params = params.with_indifferent_access
    [:rocky_request, :voter_records_request, :voter_registration].tap do |keys|
      value = params
      keys.each do |key|
        unless (value = value[key.to_s])
          raise "Invalid request: parameter #{keys.join('.')} not found"
        end
      end
    end    
    registrant = V4::RegistrationService.create_pa_registrant(params[:rocky_request])    
    registrant.basic_character_replacement!
    registrant.state_ovr_data ||= {}
    registrant.state_ovr_data["grommet_request_id"] = self.id
    
    if registrant.valid?
      # If valid for rocky, ensure that it's valid for PA submissions
      pa_validation_errors = V4::RegistrationService.valid_for_pa_submission(registrant)
      if pa_validation_errors.any?
        raise pa_validation_errors.inspect
      else
        # If there are no errors, make the submission to PA
        # This will commit the registrant with the response code
        registrant.save!
        V4::RegistrationService.delay.async_register_with_pa(registrant.id)
        return true
      end
    else
      raise registrant.errors.full_messages.join("\n")
    end
  end

  def self.upload_request_results_report_csv(state)
    contents = GrommetRequest.request_results_report_csv(state)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['PDF_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key    => ENV['PDF_AWS_SECRET_ACCESS_KEY'],
      :region                   => 'us-west-2'
    })
    bucket_name = "rtv-reports"
    directory = connection.directories.get(bucket_name)
    file = directory.files.create(
      :key    => "#{Rails.env}/grommet_requests_#{state}.csv",
      :body   => contents,
      :content_type => "text/csv",
      :encryption => 'AES256', #Make sure its encrypted on their own hard drives
      :public => true
    )
    Settings.send("grommet_csv_ready_#{state.to_s.downcase}=", true)
    Settings.send("grommet_csv_generated_at_#{state.to_s.downcase}=", DateTime.now)
    Settings.send("grommet_csv_url_#{state.to_s.downcase}=", "https://s3-us-west-2.amazonaws.com/rtv-reports/#{Rails.env}/grommet_requests_#{state}.csv")
  end

  def self.request_results_report_csv(state)
    self.send("request_results_report_csv_#{state.downcase}")
  end

  def self.request_results_report_csv_pa
    # Only look at registrants within the last 4 months to narrow the scope.
    # If want full scope, go back to March 29, 2018
    distribute_reads(failover: false) do
      start_date = 4.months.ago
      rs = Registrant.where("created_at > ?", start_date).where("state_ovr_data IS NOT NULL")
      gs = GrommetRequest.where(state: "PA").where('created_at > ?', start_date + 2.days)
      r_reqs = {}
    
      dj_ids = Delayed::Job.all.pluck(:id)
    
      rs.find_each do |r|
        if r.is_grommet? && !r.grommet_request_id.blank?
          in_queue = ""
          dj_id = r.state_ovr_data["delayed_job_id"]
          if dj_id && dj_ids.include?(dj_id)
            in_queue = "queued"
          end
          r_reqs[r.grommet_request_id.to_s] = [
            r.id, 
            r.home_state_abbrev, 
            in_queue, 
            r.state_transaction_id, 
            r.vr_application_submission_errors
          ]
        end
      end
    
    
    
      req_hashes= {}
      gs.find_each do |g|
        if !g.request_hash.blank?
          req_hashes[g.request_hash] ||= []
          req_hashes[g.request_hash].push(g.id)
        end
      end

      csvstr = CSV.generate do |csv|
        csv << ["Grommet Request ID", "Partner ID", "Grommet Version", "Generated At", "Submitted At", "Session ID", "Event Location", "Event Zip", "First Name", "Last Name", "Registrant ID", "Registrant Home State", "In Queue", "PA Transaction ID", "PA Errors", "Is Duplicate Of","Is Duplicated By"]
      
      
        gs.find_each do |g|
          params = g.request_params.is_a?(Hash) || g.request_params.is_a?(ActionController::Parameters) ? g.request_params : YAML::load(g.request_params)
          params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
          params = params.with_indifferent_access
          req = params["rocky_request"]
          if req.nil?
            next
          end
          rep_fields = [
            req["partner_id"],
            begin
              if g.request_headers.to_s =~ /HTTP_GROMMET_VERSION\"=>\"([\d\.]+)\"/
                $1
              else
                nil
              end
            rescue
              nil
            end,
            begin
              req["voter_records_request"]["generated_date"]
            rescue
              nil
            end, 
            g.created_at, 
            req["source_tracking_id"], 
            req["open_tracking_id"], 
            req["partner_tracking_id"], 
            begin
              req["voter_records_request"]["voter_registration"]["name"]["first_name"]
            rescue
              ""
            end,
            begin
              req["voter_records_request"]["voter_registration"]["name"]["last_name"]
            rescue
              ""
            end
            ]
          if r_reqs[g.id.to_s]
            csv << [g.id] + rep_fields + r_reqs[g.id.to_s]
          else
            if !g.request_hash.blank?
              rh_ids = req_hashes[g.request_hash].dup
              if rh_ids && rh_ids.length <= 1
                csv << [g.id] + rep_fields + [nil,nil,nil,nil,nil,nil,nil]
              else
                # Am I the first
                first_id = rh_ids.shift if rh_ids
                if first_id == g.id
                  csv << [g.id] + rep_fields + [nil,nil,nil,nil,nil,nil,rh_ids]
                else
                  csv << [g.id] + rep_fields + [nil,nil,nil,nil,nil,first_id,nil]
                end              
              end
            else
              csv << [g.id] + rep_fields
            end
          end
        end
      end
      return csvstr
    end
  end


  def self.request_results_report_csv_mi
    # Only look at registrants within the last 4 months to narrow the scope.
    # If want full scope, go back to March 01, 2021
    distribute_reads(failover: false) do
      start_date = 4.months.ago
      mi_rs = StateRegistrants::MIRegistrant.where("created_at > ?", start_date).where("grommet_request_id IS NOT NULL")
      gs = GrommetRequest.where(state: "MI").where('created_at > ?', start_date + 2.days)
      r_reqs = {}
    
      dj_ids = Delayed::Job.all.pluck(:id)
    
      mi_rs.find_each do |mi_r|
        r = mi_r.registrant
        if r.state_ovr_data
          in_queue = ""
          dj_id = r.state_ovr_data["delayed_job_id"]
          if dj_id && dj_ids.include?(dj_id)
            in_queue = "queued"
          end
          r_reqs[mi_r.grommet_request_id.to_s] = [
            r.id, 
            r.home_state_abbrev, 
            in_queue, 
            r.state_transaction_id, 
            r.vr_application_submission_errors
          ]
        end
      end
    
    
    
      req_hashes= {}
      gs.find_each do |g|
        if !g.request_hash.blank?
          req_hashes[g.request_hash] ||= []
          req_hashes[g.request_hash].push(g.id)
        end
      end

      csvstr = CSV.generate do |csv|
        headers = ["Grommet Request ID", 
          "Partner ID", 
          "Grommet Version", 
          "Submitted At", 
          "Session ID", 
          "Name", 
          "Registrant ID", 
          "Registrant Home State", 
          "In Queue", 
          "MI Transaction ID", 
          "MI Errors", 
          "Is Duplicate Of",
          "Is Duplicated By",          
        ]

        unless Rails.env.production?
          headers << "Raw Request (not present on prod)"
        end

        csv << headers
      
      
        gs.find_each do |g|
          params = g.request_params.is_a?(Hash) ? g.request_params : YAML::load(g.request_params)
          params = params.with_indifferent_access
          req = params["rocky_request"]
          if req.nil?
            req = {}
          end
          rep_fields = [
            req["partner_id"],
            begin
              if g.request_headers.to_s =~ /HTTP_GROMMET_VERSION\"=>\"([\d\.]+)\"/
                $1
              else
                nil
              end
            rescue
              nil
            end,
            g.created_at,
            req["shift_id"],
            begin
              req["full_name"]
            rescue
              ""
            end,
            ]
          record_array  = []
          if r_reqs[g.id.to_s]
            record_array = [g.id] + rep_fields + r_reqs[g.id.to_s] + [nil, nil]
          else
            if !g.request_hash.blank?
              rh_ids = req_hashes[g.request_hash].dup
              if rh_ids && rh_ids.length <= 1
                record_array = [g.id] + rep_fields + [nil,nil,nil,nil,nil,nil,nil]
              else
                # Am I the first
                first_id = rh_ids.shift if rh_ids
                if first_id == g.id
                  record_array = [g.id] + rep_fields + [nil,nil,nil,nil,nil,nil,rh_ids]
                else
                  record_array = [g.id] + rep_fields + [nil,nil,nil,nil,nil,first_id,nil]
                end              
              end
            else
              csv << [g.id] + rep_fields
            end
          end
          unless Rails.env.production?
            record_array << params
          end
          csv << record_array
        end
      end
      return csvstr
    end
  end
  
end
