class GrommetRequest < ActiveRecord::Base
  # attr_accessible :title, :body
  
  after_create :generate_request_hash
  
  def generate_request_hash
    params = self.request_params.is_a?(Hash) ? self.request_params : YAML::load(self.request_params)
    if params["rocky_request"] && params["rocky_request"]["voter_records_request"]
      r = params["rocky_request"]["voter_records_request"]["voter_registration"]
      d = params["rocky_request"]["voter_records_request"]["generated_date"]
      key = "#{d}-#{r}"
      self.request_hash = Digest::MD5.hexdigest(key) 
      puts key, request_hash
      save(validate: false)    
    end
  end
    
    
  def is_duplicate?
    self.class.where(request_hash: self.request_hash).length > 1
  end
  
  def resubmit
    registrant = nil
    params = YAML::load(self.request_params).with_indifferent_access
    [:rocky_request, :voter_records_request, :voter_registration].tap do |keys|
      value = params
      keys.each do |key|
        unless (value = value[key.to_s])
          raise "Invalid request: parameter #{keys.join('.')} not found"
        end
      end
    end    
    registrant = V3::RegistrationService.create_pa_registrant(params[:rocky_request])    
    registrant.basic_character_replacement!
    registrant.state_ovr_data ||= {}
    registrant.state_ovr_data["grommet_request_id"] = self.id
    
    if registrant.valid?
      # If valid for rocky, ensure that it's valid for PA submissions
      pa_validation_errors = V3::RegistrationService.valid_for_pa_submission(registrant)
      if pa_validation_errors.any?
        raise pa_validation_errors.inspect
      else
        # If there are no errors, make the submission to PA
        # This will commit the registrant with the response code
        registrant.save!
        V3::RegistrationService.delay.async_register_with_pa(registrant.id)
        return true
      end
    else
      raise registrant.errors.full_messages.join("\n")
    end
  end

  def self.request_results_report_csv
    # Only look at registrants within the last 4 months to narrow the scope. If want full scope, go back to March 29, 2018
    start_date = 4.months.ago
    rs = Registrant.where("created_at > ?", start_date).where(home_state_id: GeoState["PA"].id).where("state_ovr_data IS NOT NULL")
    gs = GrommetRequest.where('created_at > ?', start_date + 2.days)
    r_reqs = {}
    rs.find_each do |r|
      if r.is_grommet? && !r.state_ovr_data["grommet_request_id"].blank?
        r_reqs[r.state_ovr_data["grommet_request_id"].to_s] = [r.id, r.state_ovr_data["pa_transaction_id"]]
      end
    end
    
    csvstr = CSV.generate do |csv|
      csv << ["Grommet Request ID", "Partner ID", "Generated At", "Submitted At", "Session ID", "Event Location", "Event Zip", "First Name", "Last Name", "Registrant ID", "PA Transaction ID", "Is Duplicate Of"]
      gs.find_each do |g|
        params = YAML.load(g.request_params)
        req = params["rocky_request"]
        rep_fields = [req["partner_id"], req["voter_records_request"]["generated_date"], g.created_at, req["source_tracking_id"], req["open_tracking_id"], req["partner_tracking_id"], req["voter_records_request"]["voter_registration"]["name"]["first_name"], req["voter_records_request"]["voter_registration"]["name"]["last_name"]]
        if r_reqs[g.id.to_s]
          csv << [g.id] + rep_fields + r_reqs[g.id.to_s]
        else
          if !g.request_hash.blank?
            other_ids = gs.where(request_hash: g.request_hash).where("id != ?", g.id) 
            csv << [g.id] + rep_fields + [nil,nil,nil,other_ids.pluck(:id)]
          else
            csv << [g.id] + rep_fields
          end
        end
      end
    end
    return csvstr
  end
  
end
