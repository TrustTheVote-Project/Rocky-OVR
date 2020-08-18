module AbrStateMethods::NC
  
  PDF_FIELDS = {
    "Voter's Last Name": {
      method: "last_name"
    },
    "Voter's First Name": {
      method: "first_name"
    },
    "Voter's Middle Name": {
      method: "middle_name"
    },
    "Voter's Suffix": {
      method: "name_suffix"
    },
    "Voter's Month of Birth": {
      method: "date_of_birth_mm"
    },
    "Voter's Date of Birth": {
      method: "date_of_birth_dd"
    },
    "Voter's Year of Birth": {
      method: "date_of_birth_yyyy"
    },
    "Voter's Previous Last Name": {},
    "Voter's Previous First Name": {},
    "Voter's Previous Middle Name": {},
    "NC Driver Licence or NCID Number": {},
    "SSN1": {},
    "SSN2": {},
    "SSN3": {},
    "SSN4": {},
    "Voter's Current NC Residential Street Address": {
      method: "address"
    },
    "Voter's regular mailing address": {},
    "Moved Month": {},
    "Moved Date": {},
    "Moved Year": {},
    "Voter's Residential City": {
      method: "city"
    },
    "Voter's Residential State": {
      method: "home_state_abbrev"
    },
    "Voter's Residential Zip Code": {
      method: "zip"
    },
    "Voter's Residential County": {},
    "Voter's E-mail address": {
      method: "email"
    },
    "Voter's phone number": {
      method: "phone"
    },
    "Mailing Address for Ballot": {},
    "Check if you would like to request absentee ballots for all elections": { options: ["Off", "On"], value: "Off" },
    "Mailing City": {},
    "Mailing State": {},
    "Mailing Zip Code": {},
    "Near Relative or Legal Guardian's Name": {},
    "Near Relative or Legal Guardian's Relationship to Voter": {},
    "Near Relative or Legal Guardian's Address": {},
    "Near Relative or Legal Guardian's City": {},
    "Near Relative or Legal Guardian's State": {},
    "Near Relative or Legal Guardian's Zip Code": {},
    "Voter Assistants Name": {},
    "Voter Assistant's Address": {},
    "Voter Assistant's City": {},
    "Voter Assistant's State": {},
    "Voter Assistant's Zip Code": {},
    "Name and Address of Facility": {},
    "Patient Yes": { options: ["Off", "On"] },
    "Patient No": { options: ["Off", "On"] },
    "Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence": { options: ["Off", "On"] },
    "US citizen outside the United States": { options: ["Off", "On"] },
    "Overseas Address": {},
    "Overseas Mailing Address": {},
    "Overseas E-Mail address": {},
    "Overseas Fax Number": {},
    "lived_here_long": { options: ["No", "Yes"] },
    #"voter_signature": {},
    #"other_signature": {},
    #"date_signed_voter": {},
    #"date_signed_other": {},
  }
  EXTRA_FIELDS = ["ssn1234", "has_mailing_address", "identification", "previous_name", "ballot_address", "relative_request", "assistant", "patient", "uocava", "uocava_ballot", "date_moved"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"Voter's Residential County": {type: :select, required: true, include_blank: true, options: [
        "Alamance",
        "Alexander",
        "Alleghany",
        "Anson",
        "Ashe",
        "Avery",
        "Beaufort",
        "Bertie",
        "Bladen",
        "Brunswick",
        "Buncombe",
        "Burke",
        "Cabarrus",
        "Caldwell",
        "Camden",
        "Carteret",
        "Caswell",
        "Catawba",
        "Chatham",
        "Cherokee",
        "Chowan",
        "Clay",
        "Cleveland",
        "Columbus",
        "Craven",
        "Cumberland",
        "Currituck",
        "Dare",
        "Davidson",
        "Davie",
        "Duplin",
        "Durham",
        "Edgecombe",
        "Forsyth",
        "Franklin",
        "Gaston",
        "Gates",
        "Graham",
        "Granville",
        "Greene",
        "Guilford",
        "Halifax",
        "Harnett",
        "Haywood",
        "Henderson",
        "Hertford",
        "Hoke",
        "Hyde",
        "Iredell",
        "Jackson",
        "Johnston",
        "Jones",
        "Lee",
        "Lenoir",
        "Lincoln",
        "McDowell",
        "Macon",
        "Madison",
        "Martin",
        "Mecklenburg",
        "Mitchell",
        "Montgomery",
        "Moore",
        "Nash",
        "New Hanover",
        "Northampton",
        "Onslow",
        "Orange",
        "Pamlico",
        "Pasquotank",
        "Pender",
        "Perquimans",
        "Person",
        "Pitt",
        "Polk",
        "Randolph",
        "Richmond",
        "Robeson",
        "Rockingham",
        "Rowan",
        "Rutherford",
        "Sampson",
        "Scotland",
        "Stanly",
        "Stokes",
        "Surry",
        "Swain",
        "Transylvania",
        "Tyrrell",
        "Union",
        "Vance",
        "Wake",
        "Warren",
        "Washington",
        "Watauga",
        "Wayne",
        "Wilkes",
        "Wilson",
        "Yadkin",
        "Yancey",
      ]}},
      {"lived_here_long": {type: :radio}},
      {"date_moved": {visible: "lived_here_long_no", min: 10, max: 10, required: :if_visible}}, #TODO- map to 4 items above: lines 37-39
      {"identification": {
        type: :radio,
        required: true,
        options: ["dln", "ssn"]}},
      {"NC Driver Licence or NCID Number": {visible: "identification_dln", required: :if_visible}},
      {"ssn1234": {visible: "identification_ssn", required: :if_visible}}, #TODO- map to 4 items above: lines 29-32
      {"has_mailing_address": {type: :checkbox}},
      {"Voter's regular mailing address": {visible: "has_mailing_address"}},
      {"ballot_address": {type: :checkbox}},
      {"Mailing Address for Ballot": {visible: "ballot_address"}},
      {"Mailing City": {visible: "ballot_address"}},
      {"Mailing State": {visible: "ballot_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing Zip Code": {visible: "ballot_address", min: 5, max: 10}},
      {"previous_name": {type: :checkbox}},
      {"Voter's Previous Last Name": {visible: "previous_name"}},
      {"Voter's Previous First Name": {visible: "previous_name"}},
      {"Voter's Previous Middle Name": {visible: "previous_name"}},
      {"uocava": {type: :checkbox}},
      {"Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence": {visible: "uocava", type: :checkbox}},
      {"US citizen outside the United States": {visible: "uocava", type: :checkbox}},
      {"Overseas Address": {visible: "uocava"}},
      {"uocava_ballot": {visible: "uocava", type: :radio, options: ["mail", "email"]}}, #TODO: autofill email if selected, or mailing address from above form field
      {"relative_request": {type: :checkbox}},
      {"Near Relative or Legal Guardian's Name": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's Relationship to Voter": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's Address": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's City": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's State": {visible: "relative_request", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Near Relative or Legal Guardian's Zip Code": {visible: "relative_request", min: 5, max: 10}},
      {"assistant": {type: :checkbox}},
      {"Voter Assistants Name": {visible: "assistant"}},
      {"Voter Assistant's Address": {visible: "assistant"}},
      {"Voter Assistant's City": {visible: "assistant"}},
      {"Voter Assistant's State": {visible: "assistant", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Voter Assistant's Zip Code": {visible: "assistant", min: 5, max: 10}},
      {"patient": {type: :radio, options: ["Yes", "No"]}}, #TODO - map to options above, lines 73-74
      {"Name and Address of Facility": {visible: "patient_yes", required: :if_visible}}
    ]
  end
  #e.g.
  # [
  #   {"reason_instructions": {type: :instructions}}, *"reason_instructions" does NOT get put into EXTRA_FIELDS
  #   {"County": {type: :select, required: true, include_blank: true, options: [
  #     "Adams",
  #   ]}},
  #   {"Security Number": {required: true}},
  #   {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
  #   {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
  #   {"identification": {
  #     type: :radio,
  #     required: true,
  #     options: ["dln", "ssn4", "photoid"]}},
  #   {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
  #   {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/}},
  # ]
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end