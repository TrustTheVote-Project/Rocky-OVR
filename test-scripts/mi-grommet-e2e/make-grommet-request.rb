require 'json'
require 'rest-client'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v5/voterregistrationrequest/mi"

def grommet_json(full_name: "Test Name", session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, street_number: "1.0")
   json =<<EOJ
   {
      "partner_id": 1,
      "shift_id": "#{session_id}",
      "incomplete": #{street_number == "incomplete"},
      "locale": "en",
      "email": "user@domain.com",
      "phone_type": "Home",
      "updated_dln_recently": false,
      "requested_duplicate_dln_today": false,
      "confirm_us_citizen": true,
      "confirm_will_be_18": true,
      "is_30_day_resident": true,
      "registration_cancellation_authorized": true,
      "digital_signature_authorized": true,
      "full_name": "#{full_name}",
      "date_of_birth": "1916-01-01",
      "eye_color_code": "BLU",
      "dln": "A123123123123",
      "ssn4": "1234",
      "registration_address_number": "#{street_number}",
      "registration_address_street_name": "Main",
      "registration_address_street_type": "Street",
      "registration_address_post_directional": "SW",
      "registration_unit_number": "Unit A",
      "registration_city": "Lansing",
      "registration_zip_code": "48000",
      "has_mailing_address": true,
      "mailing_address_type": "STANDARD",
      "mailing_address_1": "1",
      "mailing_address_2": "Main St - #{Time.now.to_i}",
      "mailing_address_3": "",
      "mailing_address_unit_number": "",
      "mailing_city": "City",
      "mailing_state": "ME",
      "mailing_country": "",
      "mailing_zip_code": "04040",
      "opt_in_email": false,
      "opt_in_sms": false,
      "partner_opt_in_sms": false,
      "partner_opt_in_email": false,
      "partner_volunteer": false
    }
EOJ
  return JSON.parse(json)
end

def submit_registration(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, full_name: "Test Name", street_number: "1.0")
  grommet_request_json = grommet_json(session_id: session_id, partner_tracking_id: partner_tracking_id, partner_id: partner_id, full_name: full_name, street_number: street_number)
  begin
    resp = RestClient.post(URL, grommet_request_json.to_json, {content_type: :json, accept: :json})
    return resp
  rescue Exception => e
    return e.message, e.http_body
  end  
end

options = {session_id: ARGV[0], partner_tracking_id: ARGV[1], partner_id: ARGV[2], full_name: ARGV[3], street_number: ARGV[4]}.compact
puts submit_registration(options)
