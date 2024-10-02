uids = []


gids = rs.collect{ |r| r.state_ovr_data["grommet_request_id"]}


rs.each {|r| 
  g = GrommetRequest.find r.state_ovr_data["grommet_request_id"]
  grommet_submission = g.request_params["rocky_request"]["voter_records_request"]["voter_registration"]
  sig = "data:#{grommet_submission["signature"]["mime_type"]};base64,#{grommet_submission["signature"]["image"]}"
  
  puts r.uid
  puts sig
}