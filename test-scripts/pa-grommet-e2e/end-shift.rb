require 'rest-client'
require 'json'
require_relative './domain.rb'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
# URL = "#{BASE_DOMAIN}/api/v4/canvassing_shifts"
URL = "#{BASE_DOMAIN}#{BASE_PATH}/completeShift"

def clock_out(shift_id)
  resp = RestClient.get("#{URL}/#{shift_id}/complete", {content_type: :json, accept: :json})
  return resp
end

puts clock_out(ARGV[0])