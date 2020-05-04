# curl -X POST -d registration[lang]=en -d registration[date_of_birth]=1979-10-24 -d registration[email_address]=test@test.com -d registration[first_name]=Test -d registration[home_address]=Colenso -d registration[home_city]=Carrum -d registration[home_state_id]=NV -d registration[home_zip_code]=89001 -d registration[last_name]=User -d registration[name_title]=Mr. -d registration[partner_id]=1 -d registration[party]=Democratic -d registration[race]=Other -d registration[id_number]=1234 -d registration[us_citizen]=1 -d registration[opt_in_email]=1 -d registration[partner_opt_in_sms]=1 -d registration[send_confirmation_reminder_emails]=1 http://localhost:3000/api/v3/registrations.json


require 'json'
require 'rest-client'

require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v4/registrations.json"

def api_json(first_name: "Test", partner_id: 1, address: "5501 Walnut St." )
   json =<<EOJ
  {
    "registration": {
      "lang": "en",
      "date_of_birth": "1979-06-16",      
      "email_address": "alex.mekelburg@osetfoundation.org",
      "first_name": "#{first_name}",
      "home_address": "#{address}",
      "home_city": "Carrum",
      "home_state_id": "PA",
      "home_zip_code": "19001",
      "last_name": "User",
      "name_title": "Mr.",
      "partner_id": "#{partner_id}",
      "party": "Democratic",
      "race": "Other",
      "id_number": "1234",
      "us_citizen": "1",
      "opt_in_email": "1",
      "partner_opt_in_sms": "1",
      "send_confirmation_reminder_emails": "1"
    }
  }
EOJ
  return JSON.parse(json)
end

def submit_registration(partner_id: 1, first_name: "Test", address: "5501 Walnut St.")
  request_json = api_json(partner_id: partner_id, first_name: first_name, address: address)
  begin
    resp = RestClient.post(URL, request_json.to_json, {content_type: :json, accept: :json})
    return resp
  rescue Exception => e
    return e.message, e.http_body
  end
end

options = {partner_id: ARGV[0], first_name: ARGV[1], address: ARGV[2]}.compact
puts submit_registration(options)
