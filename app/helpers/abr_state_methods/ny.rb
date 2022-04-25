module AbrStateMethods::NY
  
  COUNTIES = [
    "Albany County",
    "Allegany County",
    "Bronx County",
    "Broome County",
    "Cattaraugus County",
    "Cayuga County",
    "Chautauqua County",
    "Chemung County",
    "Chenango County",
    "Clinton County",
    "Columbia County",
    "Cortland County",
    "Delaware County",
    "Dutchess County",
    "Erie County",
    "Essex County",
    "Franklin County",
    "Fulton County",
    "Genesee County",
    "Greene County",
    "Hamilton County",
    "Herkimer County",
    "Jefferson County",
    "Kings County (Brooklyn)",
    "Lewis County",
    "Livingston County",
    "Madison County",
    "Monroe County",
    "Montgomery County",
    "Nassau County",
    "New York County (Manhattan)",
    "Niagara County",
    "Oneida County",
    "Onondaga County",
    "Ontario County",
    "Orange County",
    "Orleans County",
    "Oswego County",
    "Otsego County",
    "Putnam County",
    "Queens County",
    "Rensselaer County",
    "Richmond County (Staten Island)",
    "Rockland County",
    "Saint Lawrence County",
    "Saratoga County",
    "Schenectady County",
    "Schoharie County",
    "Schuyler County",
    "Seneca County",
    "Steuben County",
    "Suffolk County",
    "Sullivan County",
    "Tioga County",
    "Tompkins County",
    "Ulster County",
    "Warren County",
    "Washington County",
    "Wayne County",
    "Westchester County",
    "Wyoming County",
    "Yates County",
  ]

  PDF_FIELDS = {
    "abr_email": { method: "email" },
    "abr_reason_instructions": {},
    "abr_reason_selections": { options: [
      "abr_reason1",
      "abr_reason2",
      "abr_reason3",
      "abr_reason4",
      "abr_reason5",
      "abr_reason6",
    ]},
    "abr_first_name": { method: "first_name" },	
    "abr_middle_initial": { method: "middle_initial" },	
    "abr_last_name": { method: "last_name" },	
    "abr_name_suffix": { method: "name_suffix" },	
    "abr_date_of_birth_complete": { method: "date_of_birth_mm_dd_yyyy" },	
    "abr_address_line_1": { method: "address_line_1" },
    "abr_unit": { method: "unit" },	
    "abr_city": { method: "city" },	
    "abr_county": {},	
    "abr_home_state_abbrev": { method: "home_state_abbrev" },	
    "abr_zip": { method: "zip" },	
    "abr_election_type_selections": {
      options: [
        "abr_election_type1",
        "abr_election_type2",
        "abr_election_type3",
        "abr_election_type4",
      ]
    },	
    "abr_absence_begin_date": {
      method: "absence_begin_date_string"
    },
    "abr_absence_end_date": {
      method: "absence_end_date_string"
    },
    "abr_address_type_selections": {
      options: [
        "abr_address_type2",
        "abr_address_type3",
        "abr_address_type4",
      ]
    },	
    "abr_request_name": {},	
    "abr_mailing_address_instructions": {},	
    "abr_mailing_street_number": { },	
    "abr_mailing_street_name": {},	
    "abr_mailing_unit": {},	
    "abr_mailing_city": {},	
    "abr_mailing_state_abbrev": {},	
    "abr_mailing_zip": {},	
    "abr_address_type_selections2": {
      options: [
        "abr_address_type6",
        "abr_address_type7",
        "abr_address_type8",
      ]
    },	
    "abr_request_name2": {},	
    "abr_mailing_address_instructions2": {},	
    "abr_mailing_street_number1": {},	
    "abr_mailing_street_name1": {},	
    "abr_mailing_unit1": {},	
    "abr_mailing_city1": {},	
    "abr_mailing_state_abbrev1": {},	
    "abr_mailing_zip1": {},	
    "abr_witness_check1": {options: ["Off", "Yes"]},	
    "abr_assistant_instructions": {},
    "abr_assistant_address_line1": {},
    "abr_assistant_address_line2": {},
    "abr_phone": { method: "phone" },	
  }

  EXTRA_FIELDS = ["absence_begin_date_mm", "absence_begin_date_dd", "absence_begin_date_yyyy",
    "absence_end_date_mm", "absence_end_date_dd", "absence_end_date_yyyy",
  "primary_registration_address_check", "general_registration_address_check"]
  
  
  def form_field_items
    [
      {"abr_reason_instructions": {type: :instructions}},
      {"abr_reason_selections": {type: :radio, required: true}},
      {"abr_county": {type: :select,  required: true, include_blank: true, options: COUNTIES }},	
      {"abr_election_type_selections": {type: :radio, required: true}},	
      {"absence_begin_date": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type4"}},
      {"absence_end_date": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type4"}},
      {"abr_address_type_selections": {type: :radio, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type_selections_abr_election_type4"}},
      {"primary_registration_address_check": {type: :checkbox, visible: "abr_address_type_selections_abr_address_type3"}}, 
      {"abr_request_name": {required: :if_visible, visible: "abr_address_type_selections_abr_address_type4"}},
      {"abr_mailing_address_instructions": {type: :instructions, hidden: "primary_registration_address_check", visible:  "abr_address_type_selections_abr_address_type3"}},	
      {"abr_mailing_street_number": {classes: "quarter", required: :if_visible, hidden: "primary_registration_address_check", visible: "abr_address_type_selections_abr_address_type3"}},	
      {"abr_mailing_street_name": {classes: "half", required: :if_visible, hidden: "primary_registration_address_check", visible: "abr_address_type_selections_abr_address_type3"}},	
      {"abr_mailing_unit": {classes: "quarter", hidden: "primary_registration_address_check", visible: "abr_address_type_selections_abr_address_type3"}},	
      {"abr_mailing_city": {classes: "half", required: :if_visible, hidden: "primary_registration_address_check", visible: "abr_address_type_selections_abr_address_type3"}},	
      {"abr_mailing_state_abbrev": {classes: "quarter", required: :if_visible, hidden: "primary_registration_address_check",  visible: "abr_address_type_selections_abr_address_type3", type: :select, options: GeoState.collection_for_select}},	
      {"abr_mailing_zip": {classes: "quarter", required: :if_visible, hidden: "primary_registration_address_check", visible: "abr_address_type_selections_abr_address_type3"}},	
      {"abr_address_type_selections2": {type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type2 abr_election_type_selections_abr_election_type3 abr_election_type_selections_abr_election_type4"}},
      
      {"abr_request_name2": {required: :if_visible,visible: "abr_address_type_selections2_abr_address_type8"}},
      
      {"general_registration_address_check": {type: :checkbox, visible: "abr_address_type_selections2_abr_address_type7"}}, 
      
      {"abr_mailing_address_instructions2": {type: :instructions, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},
      {"abr_mailing_street_number1": {classes: "quarter", required: :if_visible, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},
      {"abr_mailing_street_name1": {classes: "half", required: :if_visible, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},	
      {"abr_mailing_unit1": {classes: "quarter", hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},	
      {"abr_mailing_city1": {classes: "half", required: :if_visible, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},	
      {"abr_mailing_state_abbrev1": {classes: "quarter", required: :if_visible, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7", type: :select, options: GeoState.collection_for_select}},	
      {"abr_mailing_zip1": {classes: "quarter", required: :if_visible, hidden: "general_registration_address_check", visible: "abr_address_type_selections2_abr_address_type7"}},	
      
      {"abr_witness_check1": {type: :checkbox}},	
      {"abr_assistant_instructions": {visible: "abr_witness_check1"}},
      {"abr_assistant_address_line1": {visible: "abr_witness_check1", required: :if_visible}},
      {"abr_assistant_address_line2": {visible: "abr_witness_check1", required: :if_visible}},
    ]
  end
  
  def absence_begin_date_string
    date_field_string_mm_dd_yyyy(method: :absence_begin_date)
  end
  def absence_end_date_string
    date_field_string_mm_dd_yyyy(method: :absence_end_date)
  end

  def custom_form_field_validations  
  end


  def abr_mailing_street_number
    self.primary_registration_address_check == "1" ? street_number : get_attribute(:abr_mailing_street_number)
  end
  def abr_mailing_street_number=(value)
    set_attribute(:abr_mailing_street_number, value)
  end
  def abr_mailing_street_name
    self.primary_registration_address_check == "1" ? street_name : get_attribute(:abr_mailing_street_name)
  end
  def abr_mailing_street_name=(value)
    set_attribute(:abr_mailing_street_name, value)
  end
  def abr_mailing_unit
    self.primary_registration_address_check == "1" ? unit : get_attribute(:abr_mailing_unit)
  end
  def abr_mailing_unit=(value)
    set_attribute(:abr_mailing_unit, value)
  end
  def abr_mailing_city
    self.primary_registration_address_check == "1" ? city : get_attribute(:abr_mailing_city)
  end
  def abr_mailing_city=(value)
    set_attribute(:abr_mailing_city, value)
  end
  def abr_mailing_state_abbrev
    self.primary_registration_address_check == "1" ? home_state_abbrev : get_attribute(:abr_mailing_state_abbrev)
  end
  def abr_mailing_state_abbrev=(value)
    set_attribute(:abr_mailing_state_abbrev, value)
  end
  def abr_mailing_zip
    self.primary_registration_address_check == "1" ? zip : get_attribute(:abr_mailing_zip)
  end
  def abr_mailing_zip=(value)
    set_attribute(:abr_mailing_zip, value)
  end

  def abr_mailing_street_number1
    self.general_registration_address_check == "1" ? street_number : get_attribute(:abr_mailing_street_number1)
  end
  def abr_mailing_street_number1=(value)
    set_attribute(:abr_mailing_street_number1, value)
  end
  def abr_mailing_street_name1
    self.general_registration_address_check == "1" ? street_name : get_attribute(:abr_mailing_street_name1)
  end
  def abr_mailing_street_name1=(value)
    set_attribute(:abr_mailing_street_name1, value)
  end
  def abr_mailing_unit1
    self.general_registration_address_check == "1" ? unit : get_attribute(:abr_mailing_unit1)
  end
  def abr_mailing_unit1=(value)
    set_attribute(:abr_mailing_unit1, value)
  end
  def abr_mailing_city1
    self.general_registration_address_check == "1" ? city : get_attribute(:abr_mailing_city1)
  end
  def abr_mailing_city1=(value)
    set_attribute(:abr_mailing_city1, value)
  end
  def abr_mailing_state_abbrev1
    self.general_registration_address_check == "1" ? home_state_abbrev : get_attribute(:abr_mailing_state_abbrev1)
  end
  def abr_mailing_state_abbrev1=(value)
    set_attribute(:abr_mailing_state_abbrev1, value)
  end
  def abr_mailing_zip1
    self.general_registration_address_check == "1" ? zip : get_attribute(:abr_mailing_zip1)
  end
  def abr_mailing_zip1=(value)
    set_attribute(:abr_mailing_zip1, value)
  end
  
  
 
end