require 'rest-client'
require 'json'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "#{BASE_DOMAIN}/api/v4/canvassing_shifts"

def clock_out_json(abandoned_registrations: 0, completed_registrations: 0)
  json =<<EOJ
  {
    "abandoned_registrations": #{abandoned_registrations},
    "completed_registrations": #{completed_registrations},
    "clock_in_datetime": "#{(DateTime.now - 0.2).new_offset(0)}",
    "clock_out_datetime": "#{(DateTime.now - 0.1).new_offset(0)}"  
  }
EOJ
  return JSON.parse(json)
end

def clock_out(shift_id, abandoned_registrations: 0, completed_registrations: 0)
  json = clock_out_json(abandoned_registrations: abandoned_registrations, completed_registrations: completed_registrations)
  puts json
  resp = RestClient.put("#{URL}?shift_id=#{shift_id}", json.to_json, {content_type: :json, accept: :json})
  return resp
end

options = {abandoned_registrations: ARGV[1], completed_registrations: ARGV[2]}.compact
puts clock_out(ARGV[0], options)