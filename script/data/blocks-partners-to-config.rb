require 'csv'
require 'yaml'

partners = {}
CSV.read("web-ui-subgroups.csv", headers: true).each do |row|
  partner_id = row["RTV Partner ID"].to_i
  partner = partners[partner_id]
  if !partner
    partners[partner_id] = {
      "states" => [row["State"]],
      "url" => "https://sv#{row["State"].downcase}.blocks.im",
      "bulk_submit" => false,
      "submit_forms" => false,
      "sub_orgs" => []
    }
    partner = partners[partner_id]
  end
  partner["sub_orgs"].push({
    "name" => row["Organization Name"],
    "turf_id" => row["Blocks Turf ID"],
    "location_id" => row["location id"],
    "staging_location_id" => row["staging location id"]
  })

end


puts partners.to_yaml