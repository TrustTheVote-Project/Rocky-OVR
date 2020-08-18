module AbrStateMethods::AL
  
  PDF_FIELDS = {
    "Return this application to": {},
    "County": {},
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
      options: ["Off", "On"]
    },
    "chkReason2": {
      options: ["Off", "On"]
    },
    "chkReason3": {
      options: ["Off", "On"]
    },
    "chkReason4": {
      options: ["Off", "On"]
    },
    "chkReason5": {
      options: ["Off", "On"]
    },
    "chkReason6": {
      options: ["Off", "On"]
    },
    "chkReason7": {
      options: ["Off", "On"]
    },
    "chkReason8": {
      options: ["Off", "On"]
    },
    "chkReason9": {
      options: ["Off", "On"]
    },
    "txtEarlierExpDate": {
      method: "earlier_exp_date"
    },
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
    "Drivers_License_Number": { sensitive: true },
    "SSN_last_4": { sensitive: true },
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
  }
  EXTRA_FIELDS = ["has_mailing_address", "identification", "earlier_exp_date_dd", "earlier_exp_date_mm", "earlier_exp_date_yyyy"]
 
  def form_field_items
    [
      {"Return this application to": {}},
      {"County": {type: :select, required: true, include_blank: true, options: [
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
      {"Precinct": { required: true }},
      {"WorkPhone": {}},
      {"reason_instructions": {type: :instructions}},
      {"chkReason1": {type: :checkbox}},
      {"chkReason2": {type: :checkbox}},
      {"chkReason3": {type: :checkbox}},
      {"chkReason4": {type: :checkbox}},
      {"chkReason5": {type: :checkbox}},
      {"chkReason6": {type: :checkbox}},
      {"txtEarlierExpDate": {visible: "chkreason6", type: :date, m: "earlier_exp_date_mm", d: "earlier_exp_date_dd", y: "earlier_exp_date_yyyy"}},
      {"chkReason7": {type: :checkbox}},
      {"chkReason8": {type: :checkbox}},
      {"chkReason9": {type: :checkbox}},
      {"identification": {type: :radio, options: ["dln_yes", "dln_no"]}},
      {"Drivers_License_State": {visible: "identification_dln_yes", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Drivers_License_Number": {visible: "identification_dln_yes"}},
      {"SSN_last_4": {min: 4, max: 4, visible: "identification_dln_no"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street_Address_1": {visible: "has_mailing_address"}},
      {"City_1": {visible: "has_mailing_address"}},
      {"State_1": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP_1": {visible: "has_mailing_address", min: 5, max: 10}}, 
    ]
  end

  def earlier_exp_date
    dates = [earlier_exp_date_mm, earlier_exp_date_dd, earlier_exp_date_yyyy].collect {|d| d.blank? ? nil : d}.compact
    if dates.length == 3
      dates.join("/")
    else
      nil
    end
  end
 
  
  def custom_form_field_validations
    if self.identification.to_s == "dln_yes"
      custom_validates_presence_of("Drivers_License_Number")
      custom_validates_presence_of("Drivers_License_State")
    end
    if self.identification.to_s == "dln_no"
      custom_validates_presence_of("SSN_last_4")
    end
    if self.has_mailing_address.to_s == "1"
      ["State_1",
      "Street_Address_1",
      "City_1",
      "ZIP_1"].each do |f|
        custom_validates_presence_of(f)
      end
      
    end
  end
  
 
end