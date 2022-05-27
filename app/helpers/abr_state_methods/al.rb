module AbrStateMethods::AL
  
  PDF_FIELDS = {
    "Return this application to": { method: "delivery_full_address" },
    "County": {},
    "Email Address": {
      method: "email"
    },
    "HomePhone": {
      method: "phone"
    },
    "WorkPhone": {},
    "chkGeneralElection": {
      options: ["Off", "On"],
      value: "On"
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
    "txtSpecialOther": {
      value: ""
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
    "Mailing_Address": {},
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
    "abr_election_type_selections": {
      options: [
        "abr_election_type1",
        "abr_election_type2",
        "abr_election_type3",
        "abr_election_type4",
      ]
    },
    "abr_primary_type_selections1": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3",
        "abr_primary_type4",
      ]
    },
    "abr_primary_type4_name": {},
    "abr_primary_type_selections2": {
      options: [
        "abr_primary_type5",
        "abr_primary_type6",
        "abr_primary_type7",
        "abr_primary_type8",        
      ]
    },
    "abr_primary_type8_name": {},
    "abr_election_type4_name": {},
    "abr_primary_type_selections3": {
      options: [
        "abr_primary_type9",
        "abr_primary_type10"
      ]
    }
  }
  EXTRA_FIELDS = ["abr_application_type_check1", "has_mailing_address", "identification", "earlier_exp_date_dd", "earlier_exp_date_mm", "earlier_exp_date_yyyy"]
 
  def form_field_items
    [
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
      {"identification": {type: :radio, required: true, options: ["dln_yes", "dln_no"]}},
      {"Drivers_License_State": {visible: "identification_dln_yes", type: :select, options: GeoState.collection_for_select}},
      {"Drivers_License_Number": {visible: "identification_dln_yes", min:1, max:16, ui_regexp:'^.*$'}},
      {"SSN_last_4": {min: 4, max: 4, visible: "identification_dln_no"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address": {visible: "has_mailing_address"}},
      {"City_1": {visible: "has_mailing_address"}},
      {"State_1": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select}},
      {"ZIP_1": {visible: "has_mailing_address", min: 5, max: 10}}, 

      {"abr_election_type_selections": { type: :radio, required: true }},
      {"abr_primary_type_selections1": { type: :radio, visible: "abr_election_type_selections_abr_election_type1", required: :if_visible, }},
      {"abr_primary_type4_name": { required: :if_visible, visible: "abr_primary_type_selections1_abr_primary_type3" }},
      {"abr_primary_type_selections2": { type: :radio, visible: "abr_election_type_selections_abr_election_type2", required: :if_visible,  }},
      {"abr_primary_type8_name": { required: :if_visible, visible: "abr_primary_type_selections2_abr_primary_type7"}},
      {"abr_election_type4_name": { required: :if_visible, visible: "abr_election_type_selections_abr_election_type4" }},
      {"abr_application_type_check1": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type4"}},
      {"abr_primary_type_selections3": { type: :radio, required: :if_visible, visible: "abr_application_type_check1" }},
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
    if ![chkreason1, chkreason2, chkreason3, chkreason4, chkreason5, chkreason6].include?("1") 
      errors.add(self.class.make_method_name(:chkreason1), custom_required_message(:reason_instructions))
      errors.add(self.class.make_method_name(:chkreason2), custom_required_message(:reason_instructions))
      errors.add(self.class.make_method_name(:chkreason3), custom_required_message(:reason_instructions))
      errors.add(self.class.make_method_name(:chkreason4), custom_required_message(:reason_instructions))
      errors.add(self.class.make_method_name(:chkreason5), custom_required_message(:reason_instructions))
      errors.add(self.class.make_method_name(:chkreason6), custom_required_message(:reason_instructions))
    end

    #raise errors.full_messages.to_s
    if self.identification.to_s == "dln_yes"
      custom_validates_presence_of("Drivers_License_Number")
      custom_validates_presence_of("Drivers_License_State")
    end
    if self.identification.to_s == "dln_no"
      custom_validates_presence_of("SSN_last_4")
    end
    if self.has_mailing_address.to_s == "1"
      ["State_1",
      "Mailing_Address",
      "City_1",
      "ZIP_1"].each do |f|
        custom_validates_presence_of(f)
      end
      
    end
  end
  
 
end