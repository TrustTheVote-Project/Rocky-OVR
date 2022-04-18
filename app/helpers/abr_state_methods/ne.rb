module AbrStateMethods::NE
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_name": {method: "middle_name"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "date_of_birth_mm_pdf": {
      pdf_name: "date_of_birth_mm",
      method: "date_of_birth_mm",
    },
    "date_of_birth_dd_pdf": {
      pdf_name: "date_of_birth_dd",
      method: "date_of_birth_dd"
    },
    "date_of_birth_YYYY_pdf": {
      pdf_name: "date_of_birth_YYYY",
      method: "date_of_birth_yyyy"
    },
    "abr_address_line_1": {
      method: "address_line_1"
    },
    "abr_unit": {
      method: "unit"
    },
    "abr_address_city_state_zip": {
      method: "address_city_state_zip"
    },	
    "abr_address_type1": {
      method: "abr_address_type1_value",
      options: ["Off", "Yes"]
    },	
    "abr_check_mailing_address": {},	
    "abr_mailing_address_line_1": {},
    "abr_mailing_unit": {},	
    "abr_mailing_address_city_state_zip": {
      method: "mailing_address_city_state_zip"
    },
    "abr_election_type_selections": {
      options: [
        "abr_election_type1",
        "abr_election_type2"
      ]
    },
    "Special Election Date": {method: "election_date_string"},	
    "abr_application_type_check1": {},	
    "abr_application_type1_instructions": {},	
    "abr_primary_type_selections1": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3",
        "abr_primary_type4",
      ]
    },
    "abr_request_check": { options: ["Off", "Yes"]},	
    "abr_request_name": {},
    "abr_relationship1": {},	
    "abr_phone": { method: "phone"},	
  }
  EXTRA_FIELDS = ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip",
    "election_date_mm", "election_date_dd", "election_date_yyyy",
    "abr_check_mailing_address",
  ]
  
  def mailing_address_city_state_zip
    ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip"].collect {|f| 
      self.send(f) || nil
    }.compact.join(" ")
  end
  
  def abr_address_type1_value
    if self.abr_check_mailing_address.to_s == "1"
      return "Off"
    else
      return "Yes"
    end
  end

  def form_field_items
    [
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_line_1": {classes: "three-quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_unit": {classes: "quarter", visible: "abr_check_mailing_address"}},
      {"abr_mailing_address_city": {classes: "half",  required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_address_state": {classes: "quarter",  required: :if_visible, visible: "abr_check_mailing_address", type: :select, options: GeoState.collection_for_select}},
      {"abr_mailing_address_zip": {classes: "quarter",  required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_election_type_selections": {required: true, type: :radio}},
      {"election_date": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type2"}},
      {"abr_application_type_check1": {type: :checkbox}},
      {"abr_application_type1_instructions": {type: :instructions, visible: "abr_application_type_check1" }},
      {"abr_application_type1_instructions2": {type: :instructions, visible: "abr_application_type_check1"}},
      {"abr_primary_type_selections1": {type: :radio, visible: "abr_application_type_check1", required: :if_visible}},
      {"abr_request_check": {type: :checkbox}},
      {"abr_request_name": {required: :if_visible, visible: "abr_request_check"}},
      {"abr_relationship1": {required: :if_visible, visible: "abr_request_check"}},
    ]
  end  
  
  def custom_form_field_validations
  end
  
  def election_date_string
    date_field_string_mm_dd_yyyy(method: :election_date)
  end

 
end