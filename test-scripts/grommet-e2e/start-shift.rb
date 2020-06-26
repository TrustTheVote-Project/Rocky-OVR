require 'rest-client'
require 'json'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v4/clockIn"

def clock_in_json(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1)
  json =<<EOJ
  {
    "partner_id": "#{partner_id}",
    "canvass_location_id": "location-123",
    "shift_id": "#{session_id}",
    "source_tracking_id": "Custom Tracking Value",
    "partner_tracking_id": "#{partner_tracking_id}",
    "geo_location": {
      "lat": 123,
      "long": -123
    },
    "open_tracking_id": "metro canvasing",
    "canvasser_name": "Test Canvasser",
    "canvasser_phone": "123-123-1234",
    "device_id": "234834",
    "clock_in_datetime": "#{DateTime.now.new_offset(0)}"
  }
EOJ
  return JSON.parse(json)
end

def clock_in(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1)
  json = clock_in_json(session_id: session_id, partner_tracking_id: partner_tracking_id, partner_id: partner_id)
  puts json
  resp = RestClient.post(URL, json.to_json, {content_type: :json, accept: :json})
  return resp
end

options = {session_id: ARGV[0], partner_tracking_id: ARGV[1], partner_id: ARGV[2]}.compact
puts clock_in(options)