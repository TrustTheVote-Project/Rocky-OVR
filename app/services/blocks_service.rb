class BlocksService
  
  def self.form_from_registrant(r)
    {
      date_of_birth: r.date_of_birth&.to_s("%Y-%m-%d"),
      eligible_voting_age: true, #r.ineligible_age checks for is==18 *now* not by deadline?
      email_address: r.email_address,
      first_name: r.first_name,
      last_name: r.last_name,
      gender: r.gender,
      phone_number: r.phone,
      signature: r.is_grommet? ? r.api_submitted_with_signature : !r.existing_state_registrant&.voter_signature_image.blank?,
      us_citizen: !!r.us_citizen,
      county: r.is_grommet? ? r.home_county : r.existing_state_registrant&.registration_county,
      voting_city: r.home_city,
      voting_state: r.home_state_abbrev,
      voting_street_address_one: r.home_address,
      voting_street_address_two: r.home_unit,
      voting_zipcode: r.home_zip_code
    }
  end
  
  def initialize
    # call this immediately and outside of another RequestLogSession call
    get_token
  end
  
  def token
    @token ||= get_token
  end
  
  def get_token
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      @token = BlocksClient.get_token["jwt"]
      return @token
    end
  end
  
  def upload_complete_shift_for_partner(partner, registrants, start_time, end_time, shift_type: "voter_registration")
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
  
  #add_metadata_to_form(form_id, meta_data={}, token:)
  def add_metadata_to_form(form_id, meta_data={})
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.add_metadata_to_form(form_id, meta_data, token: self.token)
    end
  end

  def create_shift(canvasser_data)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.create_shift(canvasser_data.merge({token: self.token}))
    end
  end
  
  def upload_registrations(shift_id, forms)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.upload_registrations(shift_id, forms, token: self.token)
    end
  end
  
end