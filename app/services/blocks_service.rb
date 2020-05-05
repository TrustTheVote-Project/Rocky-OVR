class BlocksService
  def self.create_virtual_pa_partner_shifts
    shift_length = RockyConf.blocks_configuration.shift_length.hours
    shift_end = Time.now #(Time.now - 2.hours).beginning_of_hour
    shift_start = shift_end - shift_length
    
    RockyConf.blocks_configuration.partners.keys.each do |pid|
      partner = Partner.find_by_id(pid.to_s)
      registrants = []
      if partner
        started_registrants = partner.registrants.where(home_state: GeoState["PA"]).where("created_at >= ? AND created_at < ?", shift_start, shift_end)
        started_registrants.each do |r|
          registrants << r if (r.status == 'complete' || r.submitted_via_state_api?)
        end
        if registrants.any?
          service = self.new
          service.upload_complete_shift_for_partner(partner, registrants, shift_start, shift_end)
        else
          Rails.logger.info "No registrants to register for partner #{partner.id}"
        end
      end
      
    end
    
  end
  
  
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
  
  def token
    @token ||= get_token
  end
  
  def get_token
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      return BlocksClient.get_token["jwt"]
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