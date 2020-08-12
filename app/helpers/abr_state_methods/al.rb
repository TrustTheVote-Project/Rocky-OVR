module AbrStateMethods::AL
  
  PDF_FIELDS = {
    "Return this application to": {},
    "Please note that only one application may be placed in the same envelope": {},
    "Email Address": {
      method: "email"
    },
    "HomePhone": {
      method: "phone"
    },
    "WorkPhone": {},
    "chkGeneralElection": {
      options: ["General", "Off"],
      value: "General"
    },
    "chkPrimaryElection": {
      options: ["Primary", "Off"],
      value: "Off"
    },
    "chkPrimaryRunoffElection": {
      options: ["Runoff", "Off"],
      value: "Off"
    },
    "chkSpecialElection": {
      options: ["Special", "Off"],
      value: "Off"
    },
    "chkPriDem": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPriOther": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPriRep": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPriAmd": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPrrDem": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPrrRep": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPrrOther": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkPrrAmd": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkSpcDem": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkSpcRep": {
      options: ["On", "Off"],
      value: "Off"
    },
    "chkReason1": {
      options: ["On", "Off"]
    },
    "chkReason2": {
      options: ["On", "Off"]
    },
    "chkReason3": {
      options: ["On", "Off"]
    },
    "chkReason4": {
      options: ["On", "Off"]
    },
    "chkReason5": {
      options: ["On", "Off"]
    },
    "chkReason6": {
      options: ["On", "Off"]
    },
    "chkReason7": {
      options: ["On", "Off"]
    },
    "chkReason8": {
      options: ["On", "Off"]
    },
    "chkReason9": {
      options: ["On", "Off"]
    },
    "txtEarlierExpDate": {},
    "Last_Name": {
      method: "last_name"
    },
    "First_Name": {
      method: "first_name"
    },
    "Middle_Name": {
      method: "middle_name"
    },
    "Street_Address": {
      method: "address"
    },
    "Street_Address_1": {},
    "City": {
      method: "city"
    },
    "City_1": {},
    "State": {
      method: "home_state_abbrev"
    },
    "State_1": {},
    "ZIP": {
      method: "zip"
    },
    "ZIP_1": {},
    "Precinct": {},
    "Drivers_License_State": {},
    "Drivers_License_Number": {},
    "SSN_last_4": {},
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
  }
  EXTRA_FIELDS = ["has_mailing_address", "identification"]
 
  def form_field_items
    [
      {"Return this application to": {}},
      {"Please note that only one application may be placed in the same envelope": {type: :select, required: true, include_blank: true, options: [
        "Autauga",
        "Baldwin",
        "Barbour",
        "Bibb",
        "Blount",
        "Bullock",
        "Butler",
        "Calhoun",
        "Chambers",
        "Cherokee",
        "Chilton",
        "Choctaw",
        "Clarke",
        "Clay",
        "Cleburne",
        "Coffee",
        "Colbert",
        "Conecuh",
        "Coosa",
        "Covington",
        "Crenshaw",
        "Cullman",
        "Dale",
        "Dallas",
        "De Kalb",
        "Elmore",
        "Escambia",
        "Etowah",
        "Fayette",
        "Franklin",
        "Geneva",
        "Greene",
        "Hale",
        "Henry",
        "Houston",
        "Jackson",
        "Jefferson",
        "Lamar",
        "Lauderdale",
        "Lawrence",
        "Lee",
        "Limestone",
        "Lowndes",
        "Macon",
        "Madison",
        "Marengo",
        "Marion",
        "Marshall",
        "Mobile",
        "Monroe",
        "Montgomery",
        "Morgan",
        "Perry",
        "Pickens",
        "Pike",
        "Randolph",
        "Russell",
        "St. Clair",
        "Shelby",
        "Sumter",
        "Talladega",
        "Tallapoosa",
        "Tuscaloosa",
        "Walker",
        "Washington",
        "Wilcox",
        "Winston",
      ]}},
      {"Precinct": {}},
      {"WorkPhone": {}},
      #TODO- we need a title here for instructions for the following set of checkboxes: "I am applyig for an absentee ballot because:"
      {"chkReason1": {type: :checkbox}},
      {"chkReason2": {type: :checkbox}},
      {"chkReason3": {type: :checkbox}},
      {"chkReason4": {type: :checkbox}},
      {"chkReason5": {type: :checkbox}},
      {"chkReason6": {type: :checkbox}},
      {"txtEarlierExpDate": {visible: "chkreason6"}}, #TODO- broken?
      {"chkReason7": {type: :checkbox}},
      {"chkReason8": {type: :checkbox}},
      {"chkReason9": {type: :checkbox}},
      {"identification": {type: :radio, options: ["dln_yes", "dln_no"]}},
      {"Drivers_License_State": {visible: "identification_dln_yes", min: 2, max: 2}},
      {"Drivers_License_Number": {visible: "identification_dln_yes"}},
      {"SSN_last_4": {min: 4, max: 4, visible: "identification_dln_no"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street_Address_1": {visible: "has_mailing_address"}},
      {"City_1": {visible: "has_mailing_address"}},
      {"State_1": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP_1": {visible: "has_mailing_address", min: 5, max: 10}}, 
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