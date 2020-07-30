require 'rest-client'
require 'json'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v4/canvassing_shifts"

def clock_in_json(partner_tracking_id: "custom tracking id", partner_id: 1)
  json =<<EOJ
  {
    "partner_id": "#{partner_id}",
    "shift_location": "267",
    "source_tracking_id": "Custom Tracking Value",
    "partner_tracking_id": "#{partner_tracking_id}",
    "open_tracking_id": "metro canvasing",
    "canvasser_first_name": "Test",
    "canvasser_last_name": "Canvasser",
    "canvasser_email": "test@test.test",
    "canvasser_phone": "123-123-1234",
    "device_id": "234834"
  }
EOJ
  return JSON.parse(json)
end

def clock_in(partner_tracking_id: "custom tracking id", partner_id: 1)
  json = clock_in_json(partner_tracking_id: partner_tracking_id, partner_id: partner_id)
  resp = RestClient.post(URL, json.to_json, {content_type: :json, accept: :json})
  return resp
end

options = {partner_tracking_id: ARGV[0], partner_id: ARGV[1]}.compact
puts JSON.parse(clock_in(options))["shift_id"]