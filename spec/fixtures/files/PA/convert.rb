require_relative '../../../../app/services/vr_to_pa'
require '../../../../app/services/phone_formatter'
require 'json'
require 'date'

Dir.glob('in_rocky_requests/*.json') do |json_file|
  json = JSON.load(File.open(json_file))
  output = VRToPA.new(json["rocky_request"]["voter_records_request"]).convert
  path = File.join("out_pa_request_data", File.basename(json_file, ".json") + ".out.json")
  File.write(path, output.to_json)
end
