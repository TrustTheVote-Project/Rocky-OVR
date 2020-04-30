class BlocksService
  
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
        {
          date_of_birth: "2000-01-01",
          eligible_voting_age: true,
          email_address: "",
          first_name: "Voter",
          last_name: "One",
          gender: "M",
          phone_number: "123-123-1234" ,
          signature: false,
          us_citizen: true,
          county: "",
          voting_city: "Salem",
          voting_state: "OR",
          voting_street_address_one: "123 Main St",
          voting_street_address_two: "",
          voting_zipcode: "97301"
        }
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
  
  
  def create_shift(canvasser_id:, location_id:, staging_location_id:, shift_start:, shift_end:, shift_type:, soft_count_cards_total_collected:)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      BlocksClient.create_shift(canvasser_id: canvasser_id, location_id: location_id, staging_location_id: staging_location_id, shift_start: shift_start, shift_end: shift_end, shift_type: shift_type, soft_count_cards_total_collected: soft_count_cards_total_collected, token: self.token)
    end
  end
  
  def upload_registrations(shift_id, forms)
    RequestLogSession.make_call_with_logging(registrant: nil, client_id: 'blocks') do
      BlocksClient.create_shift(shift_id, forms, token: self.token)
    end
  end
  
end