class BlocksFormDisposition < ActiveRecord::Base
  validates_presence_of :blocks_form_id
  
  belongs_to :grommet_request, optional: true
  belongs_to :registrant, primary_key: :uid, optional: true

  def self.submit_updates!
    updatable = self.where(final_state_submitted: false)
    if updatable.any?
      updatable.each do |blocks_form_disposition|
        blocks_form_disposition.update_blocks_form
      end
    end
  end

  def update_blocks_form
    service = BlocksService.new(partner: (registrant&.partner || partner_from_grommet_request))
    status  = request_status
    service.add_metadata_to_form(blocks_form_id, status)
    if status_complete?(status)
      self.update_attributes(final_state_submitted: true)
    end
  end
  
  def partner_from_grommet_request
    if grommet_request
      params = grommet_request.request_params.is_a?(Hash) ? grommet_request.request_params : YAML::load(grommet_request.request_params)
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params = params.with_indifferent_access
      partner_id = begin
        params["rocky_request"]["partner_id"]
      rescue
        nil
      end
      return partner_id ? Partner.find_by_id(partner_id) : nil
    end
    return nil
  end
  
  def status_complete?(status)
    return (status[:pa_transaction_id] || status[:completed_on_paper] || status[:abandoned_on_paper] || status[:is_pa_registrant]==false)
  end

  
  def base_status
    {
      has_validation_errors: false, #true | false,

      pa_submission_status: "", 
      pa_response_errors: [],
      pa_transaction_id: nil, #string | nil

      transitioned_to_paper: nil, #true | false | nil
      completed_on_paper: nil, #true | false | nil
      abandoned_on_paper: nil, #true | false | nil
    }
  end

  def grommet_request_status
    status = base_status
    status[:has_validation_errors] = self.registrant.nil?
    if self.registrant
      status[:pa_submission_status] = registrant.api_submission_status
      status[:pa_response_errors] = registrant.state_ovr_data["errors"]
      status[:pa_transaction_id] = registrant.state_ovr_data["pa_transaction_id"]
    end
    return status
  end

  def request_status
    
    status = base_status
    pa = GeoState["PA"]
    if registrant
      if registrant.is_grommet?
        return grommet_request_status
      else
        status[:has_validation_errors] = false #By definition all submittable registrant records are valid
        sr = registrant.existing_state_registrant
        if sr && registrant.home_state_id == pa.id
          if sr.pa_submission_complete
            status[:pa_submission_status] = "Submitted"
          elsif sr.penndot_retries && sr.penndot_retries > 0
            status[:pa_submission_status] = "Submitted #{sr.penndot_retries} attempts"
          else
            status[:pa_submission_status] = "Pending."
          end
          status[:pa_response_errors] = sr.pa_submission_error || []
          status[:pa_transaction_id] = sr.pa_transaction_id
          status[:transitioned_to_paper] = registrant.state_ovr_data[:skip_state_flow] == true
          if status[:transitioned_to_paper]
            status[:completed_on_paper] = registrant.complete?
            status[:abandoned_on_paper] = registrant.abandoned?
          end
          return status
        else
          return {is_pa_registrant: false } if registrant.home_state != GeoState['PA']
          #raise "Registrant #{registrant.id} has neighter StateRegistrant nor Grommet data"
        end
      end
    else
      return grommet_request_status
    end
  end
  
end
