require 'json'
require 'rest-client'

#curl -vX POST http://localhost:3000/api/v3/voterregistrationrequest -d @grommet_req.json --header "Content-Type: application/json"
URL = "http://localhost:3000/api/v4/voterregistrationrequest"

def grommet_json(first_name: "Test", session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, address: "5501 Walnut St." )
   json =<<EOJ
  {
    "rocky_request": {
      "lang": "en",
      "phone_type": "home",
      "partner_id": #{partner_id},
      "opt_in_email": false,
      "opt_in_sms": false,
      "opt_in_volunteer": false,
      "partner_opt_in_sms": true,
      "partner_opt_in_email": true,
      "partner_opt_in_volunteer": false,
      "finish_with_state": true,
      "created_via_api": true,
      "source_tracking_id": "#{session_id}",
      "partner_tracking_id": "#{partner_tracking_id}",
      "geo_location": {
        "lat": 123,
        "long": -123
      },
      "open_tracking_id": "metro canvasing",
      "voter_records_request": {
        "type": "registration",
        "generated_date": "#{DateTime.now.new_offset(0)}",
        "canvasser_name": "Test Canvasser",
        "voter_registration": {
          "registration_helper": {
            "registration_helper_type": "assistant",
            "name": {
              "first_name": "Test",
              "last_name": "Helper",
              "middle_name": "G",
              "title_prefix": "Mr",
              "title_suffix": "Jr"
            },
            "address": {
              "numbered_thoroughfare_address": {
                "complete_address_number": "",
                "complete_street_name": "5501 Walnut Street",
                "complete_sub_address":
                  {
                    "sub_address_type": "APT",
                    "sub_address": "Apt 206"
                  }
                ,
                "complete_place_names": [
                  {
                    "place_name_type": "MunicipalJurisdiction",
                    "place_name_value": "Pittsburgh"
                  },
                  {
                    "place_name_type": "County",
                    "place_name_value": "ALLEGHENY"
                  }
                ],
                "state": "PA",
                "zip_code": "15213"
              }
            },
            "contact_methods": [
              {
                "type": "phone",
                "value": "555-555-5555",
                "capabilities": [
                  "voice",
                  "fax",
                  "sms"
                ]
              }
            ]
          },
          "date_of_birth": "1990-06-16",
          "mailing_address": {
            "numbered_thoroughfare_address": {
              "complete_address_number": "",
              "complete_street_name": "5501 Walnut St.",
              "complete_sub_address":
                {
                  "sub_address_type": "APT",
                  "sub_address": "Apt 206"
                }
              ,
              "complete_place_names": [
                {
                  "place_name_type": "MunicipalJurisdiction",
                  "place_name_value": "Pittsburgh"
                },
                {
                  "place_name_type": "County",
                  "place_name_value": "ALLEGHENY"
                }
              ],
              "state": "PA",
              "zip_code": "15212-2222"
            }
          },
          "previous_registration_address": {
            "numbered_thoroughfare_address": {
              "complete_address_number": "",
              "complete_street_name": "5501 Walnut St.",
              "complete_sub_address":
                {
                  "sub_address_type": "APT",
                  "sub_address": "Apt 206"
                }
              ,
              "complete_place_names": [
                {
                  "place_name_type": "MunicipalJurisdiction",
                  "place_name_value": "Pittsburgh"
                },
                {
                  "place_name_type": "County",
                  "place_name_value": "ALLEGHENY"
                }
              ],
              "state": "MA",
              "zip_code": "15213-3333"
            }
          },
          "registration_address": {
            "numbered_thoroughfare_address": {
              "complete_address_number": "",
              "complete_street_name": "#{address}",
              "complete_sub_address":
                {
                  "sub_address_type": "APT",
                  "sub_address": "Apt 206"
                }
              ,
              "complete_place_names": [
                {
                  "place_name_type": "MunicipalJurisdiction",
                  "place_name_value": "Pittsburgh"
                },
                {
                  "place_name_type": "County",
                  "place_name_value": "ALLEGHENY"
                }
              ],
              "state": "PA",
              "zip_code": "15211-1111"
            }
          },
          "registration_address_is_mailing_address": false,
          "name": {
            "first_name": "#{first_name}",
            "last_name": "Registrant-#{rand(1000)}",
            "middle_name": "G",
            "title_prefix": "Ms",
            "title_suffix": ""
          },
          "previous_name": {
            "first_name": "Peter",
            "last_name": "Parker",
            "middle_name": "Spidy",
            "title_prefix": "Mr",
            "title_suffix": "Jr"
          },
          "gender": "male",
          "race": "American Indian / Alaskan Native",
          "party": "democratic",
          "voter_classifications": [
            {
              "type": "eighteen_on_election_day",
              "assertion": true
            },
            {
              "type": "united_states_citizen",
              "assertion": true
            },
            {
              "type": "send_copy_in_mail",
              "assertion": true
            },
            {
              "type": "agreed_to_declaration",
              "assertion": true
            }
          ],
          "signature": {
            "mime_type": "image/jpeg",
            "image": "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"
          },
          "voter_ids": [
            {
              "type": "drivers_license",
              "string_value": "99 999 999",
              "attest_no_such_id": false
            },
            {
              "type": "ssn4",
              "string_value": "5555",
              "attest_no_such_id": false
            }
          ],
          "contact_methods": [
            {
              "type": "phone",
              "value": "555-555-5555",
              "capabilities": [
                "voice",
                "fax",
                "sms"
              ]
            },
            {
              "type": "email",
              "value": "alex+test@osetfoundation.com",
              "capabilities": []
            }
          ],
          "additional_info": [
            {
              "name": "preferred_language",
              "string_value": "Spanish"
            },
            {
              "name": "assistant_declaration",
              "string_value": "true"
            }
          ]
        }
      }
    }
  }
EOJ
  return JSON.parse(json)
end

def submit_registration(session_id: "Test Canvasser::123457689", partner_tracking_id: "custom tracking id", partner_id: 1, first_name: "Test", address: "5501 Walnut St.")
  grommet_request_json = grommet_json(session_id: session_id, partner_tracking_id: partner_tracking_id, partner_id: partner_id, first_name: first_name, address: address)
  resp = RestClient.post(URL, grommet_request_json.to_json, {content_type: :json, accept: :json})
  return resp
end

options = {session_id: ARGV[0], partner_tracking_id: ARGV[1], partner_id: ARGV[2], first_name: ARGV[3], address: ARGV[4]}.compact
puts submit_registration(options)
