module AbrStateMethods::IA
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "Last Name Suffix": {
      method: "name_suffix"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Date of Birth - Month Digit 1": {}, #TODO this is effing stupid. Make it work.
    "Date of Birth - Month Digit 2": {},
    "Date of Birth - Day Digit 1": {},
    "Date of Birth - Day Digit 2": {},
    "Date of Birth - Year Digit 1": {},
    "Date of Birth - Year Digit 2": {},
    "Date of Birth - Year Digit 3": {},
    "Date of Birth - Year Digit 4": {},
    "Driver's LIcenese 1": {}, #TODO also this. WTF. I'm gonna make a thing below where they put in their license number - can you make each digit from that correspond to each of these fields? I'm hoping this is something you can make happen.
    "Driver's LIcenese 2": {},
    "Driver's LIcenese 3": {},
    "Driver's LIcenese 4": {},
    "Driver's LIcenese 5": {},
    "Driver's LIcenese 6": {},
    "Driver's LIcenese 7": {},
    "Driver's LIcenese 8": {},
    "Driver's LIcenese 9": {},
    "Four-Digit Voter PIN 1": {},
    "Four-Digit Voter PIN 2": {},
    "Four-Digit Voter PIN 3": {},
    "Four-Digit Voter PIN 4": {},
    "Home Street Address (include apt, lot, etc. if applicable)": {
      method: "address"
    },
    "Home Address City": {
      method: "city"
    },
    "Home Address Zip Code": {
      method: "zip"
    },
    "County": {},
    "Mail Address/P.O. Box": {},
    "Mailing Address City": {},
    "Mailing Address State": {},
    "Mailing Address Zip Code": {},
    "Country (Other than US)": {},
    "Phone Number": {
      method: "phone"
    },
    "Email Address": {
      method: "email"
    },
    "Do not add this contact info to my voter recored check box": { 
      options: ["Off", "Yes"] 
    },
    "Election Date - Month Digit 1": {
      value: "1"
    },
    "Election Date - Month Digit 2": {
      value: "1"
    },
    "Election Date - Day Digit 1": {
      value: "0"
    },
    "Election Date - Day Digit 2": {
      value: "3"
    },
    "Election Date - Year Digit 1": {
      value: "2"
    },
    "Election Date - Year Digit 2": {
      value: "0"
    },
    "Election Date - Year Digit 3": {
      value: "2"
    },
    "Election Date - Year Digit 4": {
      value: "0"
    },
    "Election Type": { 
      options: ["City/School Election Type", "General Election Type", "Off", "Primary Election Type", "Special Election Type"],
      value:  "General Election Type"
    },
    "Political Party - Primary Election": { 
      options: ["Democratic Party", "Off", "Republican Party"],
      value: "Off"
    }
  }
  EXTRA_FIELDS = ["identification", "license", "voter_pin", "has_mailing_address"]
   
  def form_field_items
    [
      {"identification": {type: :radio, options: ["dln", "vic"]}},
      {"license": {visible: "identification_dln", min: 9, max: 9}},
      {"voter_pin": {visible: "identification_vic", min: 4, max: 4}},
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Adair",
        "Adams",
        "Allamakee",
        "Appanoose",
        "Audubon",
        "Benton",
        "Black Hawk",
        "Boone",
        "Bremer",
        "Buchanan",
        "Buena Vista",
        "Butler",
        "Calhoun",
        "Carroll",
        "Cass",
        "Cedar",
        "Cerro Gordo",
        "Cherokee",
        "Chickasaw",
        "Clarke",
        "Clay",
        "Clayton",
        "Clinton",
        "Crawford",
        "Dallas",
        "Davis",
        "Decatur",
        "Delaware",
        "Des Moines",
        "Dickinson",
        "Dubuque",
        "Emmet",
        "Fayette",
        "Floyd",
        "Franklin",
        "Fremont",
        "Greene",
        "Grundy",
        "Guthrie",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Harrison",
        "Henry",
        "Howard",
        "Humboldt",
        "Ida",
        "Iowa",
        "Jackson",
        "Jasper",
        "Jefferson",
        "Johnson",
        "Jones",
        "Keokuk",
        "Kossuth",
        "Lee",
        "Linn",
        "Louisa",
        "Lucas",
        "Lyon",
        "Madison",
        "Mahaska",
        "Marion",
        "Marshall",
        "Mills",
        "Mitchell",
        "Monona",
        "Monroe",
        "Montgomery",
        "Muscatine",
        "O'Brien",
        "Osceola",
        "Page",
        "Palo Alto",
        "Plymouth",
        "Pocahontas",
        "Polk",
        "Pottawattamie",
        "Poweshiek",
        "Ringgold",
        "Sac",
        "Scott",
        "Shelby",
        "Sioux",
        "Story",
        "Tama",
        "Taylor",
        "Union",
        "Van Buren",
        "Wapello",
        "Warren",
        "Washington",
        "Wayne",
        "Webster",
        "Winnebago",
        "Winneshiek",
        "Woodbury",
        "Worth",
        "Wright",
      ]}},
      {"Do not add this contact info to my voter recored check box": {type: :checkbox}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mail Address/P.O. Box": {visible: "has_mailing_address"}}, #TODO- the text isn't working and there was a weird duplicate thing on the txt file.... remind me to ask you about that. 
      {"Mailing Address City": {visible: "has_mailing_address"}},
      {"Mailing Address State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing Address Zip Code": {visible: "has_mailing_address"}},
      {"Country (Other than US)": {visible: "has_mailing_address"}},
    ]
  end
  #e.g.
  # [
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