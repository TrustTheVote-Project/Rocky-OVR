class BlocksService
  
  # Notes:
  # new fields
  #   completed (needed?)
  #   proof_of_residence_image_url (required?)
  def self.form_from_registrant(r)
    form = {
      completed: r.is_grommet? ? true : r.status === 'complete',
      date_of_birth: r.date_of_birth&.to_s("%Y-%m-%d"),
      eligible_voting_age: true, #r.ineligible_age checks for is==18 *now* not by deadline?
      email_address: r.email_address,
      first_name: r.first_name,
      middle_name: r.middle_name,
      last_name: r.last_name,
      name_suffix: r.english_name_suffix,
      gender: r.gender,
      phone_number: r.phone,
      signature: r.is_grommet? ? r.api_submitted_with_signature : !r.existing_state_registrant&.voter_signature_image&.blank?,
      us_citizen: !!r.us_citizen,
      county: r.is_grommet? ? r.home_county : r.existing_state_registrant&.registration_county,
      voting_city: r.home_city,
      voting_state: r.home_state_abbrev,
      voting_street_address_one: r.home_address,
      voting_street_address_two: r.home_unit,
      voting_zipcode: r.home_zip_code,
      ethnicity: r.english_race,
      metadata: {
        rtv_uid: r.uid,
        sms_opt_in: r.partner_opt_in_sms?,
        robo_call_opt_in: r.partner_opt_in_sms?,
        email_opt_in: r.partner_opt_in_email?,
        preferred_language: r.is_grommet? ? r.grommet_preferred_language : r.locale,
        volunteer_with_partner: r.partner_volunteer?,
        phone_type: r.phone_type,
        has_state_license: (r.has_state_license? || (!r.is_grommet? && r.existing_state_registrant&.has_state_license?)),
        has_ssn: (r.has_ssn? || (!r.is_grommet? && r.existing_state_registrant&.has_ssn?)),
        
      }
    }
    begin
      form[:metadata][:original_blocks_shift_id] = r.canvassing_shift.blocks_shift_id if r.canvassing_shift
    rescue
    end
    return form
  end
  
  def self.form_from_grommet_request(req)
    params = req.request_params
    params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
    params = params.with_indifferent_access
    registrant = V4::RegistrationService.create_pa_registrant(params[:rocky_request])    
    registrant.basic_character_replacement!
    registrant.state_ovr_data ||= {}
    registrant.uid = "grommet-request-#{req.id}"
    return self.form_from_registrant(registrant)
  end

  attr_reader :partner
  
  def initialize(partner: nil)
    @partner = partner
    # call this immediately and outside of another RequestLogSession call
    get_token
  end

  def url
    (partner && RockyConf.blocks_configuration.partners[partner.id]&.url) || RockyConf.blocks_configuration.url
  end
  
  def url_client_path
    (partner && RockyConf.blocks_configuration.partners[partner.id]&.url_client_path) || RockyConf.blocks_configuration.url_client_path
  end

  def token
    @token ||= get_token
  end
  
  def get_token
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      @token = BlocksClient.get_token(url: url, url_client_path: url_client_path)["jwt"]
      return @token
    end
  end
  
  
  
  
  
  def upload_canvassing_shift(shift, shift_type: "digital_voter_registration")
    shift_params = build_canvassing_shift_blocks_hash(shift, shift_type)
    forms = shift.submit_forms? ? build_blocks_forms_from_canvassing_shift(shift) : []
    sleep(5)
    shift_response = create_shift(shift_params)
    shift_id = shift_response["shift"]["id"]
    form_responses = []
    if forms
      form_responses = upload_registrations(shift_id, forms)
    end
    return {
      shift: shift_response,
      forms: form_responses
    }
  end
  
  def upload_complete_shift_for_partner(partner, registrants, start_time, end_time, shift_type: "digital_voter_registration")
    config = RockyConf.blocks_configuration.partners[partner.id]
    soft_count_cards_total_collected = registrants.count
    if config
      canvasser_id        = config[:canvasser_id]
      location_id         = config[:location_id]
      staging_location_id = config[:staging_location_id]
      forms = registrants.map do |r|
        BlocksService.form_from_registrant(r)
      end
      shift = create_shift({
        canvasser_id: canvasser_id,
        location_id: location_id, 
        staging_location_id: staging_location_id, 
        shift_start: start_time.in_time_zone("America/New_York").iso8601, 
        shift_end: end_time.in_time_zone("America/New_York").iso8601, 
        shift_type: shift_type, 
        soft_count_cards_total_collected: soft_count_cards_total_collected
      })
      shift_id = shift["shift"]["id"]
      upload_registrations(shift_id, forms)
    end
  end
  
  def get_locations(turf_id: nil)
    turf_id ||= RockyConf.blocks_configuration.partners&.[](partner&.id)&.turf_id
    unless turf_id.blank?
      RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
        return BlocksClient.get_locations(turf_id, token: self.token, url: url, url_client_path: url_client_path)
      end
    end
    return {
      "locations" => []
    }
  end
  
  #add_metadata_to_form(form_id, meta_data={}, token:)
  # def add_metadata_to_form(form_id, meta_data={})
  #   RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
  #     return BlocksClient.add_metadata_to_form(form_id, meta_data, token: self.token, url: url, url_client_path: url_client_path)
  #   end
  # end

  def canvassers(turf_id)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.canvassers(turf_id, {token: self.token, url: url, url_client_path: url_client_path})
    end    
  end

  def create_canvasser(canvasser_data)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.create_canvasser(canvasser_data.merge({token: self.token, url: url, url_client_path: url_client_path}))
    end
  end

  def create_shift(canvasser_data)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.create_shift(canvasser_data.merge({token: self.token, url: url, url_client_path: url_client_path}))
    end
  end
  
  def upload_registrations(shift_id, forms)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      shift_status = forms.any? ? "ready_for_qc" : "ready_for_delivery"
      return BlocksClient.upload_registrations(shift_id, forms, shift_status: shift_status,  token: self.token, url: url, url_client_path: url_client_path)
    end
  end
  
  private
  def build_blocks_forms_from_canvassing_shift(shift)
    return shift.registrants_or_requests.map do |r|
      if r.is_a?(Registrant) #&& r.complete? forms with PA errors won't be complete. but some incomplete regs might fail blocks validation?
        BlocksService.form_from_registrant(r)
      elsif r.is_a?(GrommetRequest)
        BlocksService.form_from_grommet_request(r) 
      else
        nil
      end
    end.compact
  end
  
  def build_canvassing_shift_blocks_hash(shift, shift_type)
    partner_id = shift.partner_id
    partner_config = RockyConf.blocks_configuration.partners&.[](partner_id)
    turf_id = !shift.blocks_turf_id.blank? ? shift.blocks_turf_id : RockyConf.blocks_configuration.partners&.[](partner_id)&.turf_id || RockyConf.blocks_configuration.default_turf_id
    suborg_config = partner_config&.sub_orgs&.detect {|so| so.turf_id && so.turf_id.to_s == turf_id.to_s}
    
    location_id = shift.shift_location || suborg_config&.location_id || partner_config&.location_id || RockyConf.blocks_configuration.default_location_id
    staging_location_id = suborg_config&.staging_location_id || partner_config&.staging_location_id || RockyConf.blocks_configuration.default_staging_location_id
    canvasser = create_canvasser(turf_id: turf_id, last_name: shift.canvasser_last_name, first_name: shift.canvasser_first_name, email: shift.canvasser_email, phone_number: shift.canvasser_phone)
    canvasser_id = canvasser["canvasser"]["id"]
    
    soft_count_cards_total_collected      = shift.completed_registrations
    soft_count_cards_complete_collected   = shift.completed_registrations
    soft_count_cards_incomplete_collected = 0 #shift.abandoned_registrations
    soft_count_cards_with_phone_collected = 0
    begin
      forms = shift.submit_forms? ? build_blocks_forms_from_canvassing_shift(shift) : []
      soft_count_cards_with_phone_collected = forms.select {|f| !f[:phone_number].blank? }.count
    rescue
    end

    shift_params = {
      canvasser_id: canvasser_id,
      location_id: location_id,
      staging_location_id: staging_location_id, 
      shift_start: shift.clock_in_datetime.in_time_zone("America/New_York").iso8601, 
      shift_end: shift.clock_out_datetime.in_time_zone("America/New_York").iso8601, 
      #shift_type: shift_type, 
    }
    if shift.submit_forms?
      shift_params = shift_params.merge({
        soft_count_cards_total_collected: soft_count_cards_total_collected,
        soft_count_cards_complete_collected: soft_count_cards_complete_collected,
        soft_count_cards_incomplete_collected: soft_count_cards_incomplete_collected,
        soft_count_cards_with_phone_collected: soft_count_cards_with_phone_collected
      })
    end
    return shift_params
  end
  
end