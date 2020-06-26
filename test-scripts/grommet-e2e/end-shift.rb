require 'rest-client'
require 'json'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v4/clockOut"

def clock_out_json(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, abandoned_registrations: 0, completed_registrations: 0)
  json =<<EOJ
  {
    "shift_id": "#{session_id}",
    "source_tracking_id": "Custom Tracking Value",
    "partner_tracking_id": "#{partner_tracking_id}",
    "geo_location": {
      "lat": 123,
      "long": -123
    },
    "open_tracking_id": "metro canvasing",
    "canvasser_name": "Test Canvasser",
    "abandoned_registrations": #{abandoned_registrations},
    "completed_registrations": #{completed_registrations},
    "clock_out_datetime": "#{DateTime.now.new_offset(0)}"  
  }
EOJ
  return JSON.parse(json)
end

def clock_out(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, abandoned_registrations: 0, completed_registrations: 0)
  json = clock_out_json(session_id: session_id, partner_tracking_id: partner_tracking_id, partner_id: partner_id, abandoned_registrations: abandoned_registrations, completed_registrations: completed_registrations)
  puts json
  resp = RestClient.post(URL, json.to_json, {content_type: :json, accept: :json})
  return resp
end

options = {session_id: ARGV[0], partner_tracking_id: ARGV[1], partner_id: ARGV[2], abandoned_registrations: ARGV[3], completed_registrations: ARGV[4]}.compact
puts clock_out(options)