class GrommetRequest < ActiveRecord::Base
  # attr_accessible :title, :body
  
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
  
end
