module AbrStateMethods::AK
  
  PDF_FIELDS = {'abr_email': {:method=>"email"},
                'abr_first_name': {:method=>"first_name"},
                'abr_last_name': {:method=>"last_name"},
                'abr_middle_name': {method: "middle_name"},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_street_number': {method: "street_number"},
                'abr_street_name': {method: "street_name"},
                'abr_city': {:method=>"city"},
                'abr_unit': {:method=>"unit"},
                'abr_phone': {method: "phone"},
                
                
                'abr_previous_full_name': {},
                'abr_citizen_selections': {
                                            options:['abr_citizen_yes',
                                                     'abr_citizen_no']
                                          },
                'abr_18years_selections': {
                  options: ['abr_18_yes',
                            'abr_18_no']
                },
                'abr_mailing_address_line_1': {method: "abr_ballot_address"},
                'abr_mailing_unit': {method: "abr_ballot_unit"},
                'abr_mailing_city': {method: "abr_ballot_city"},
                'abr_mailing_state_abbrev': {method: "abr_ballot_state_abbrev"},
                'abr_mailing_zip': {method: "abr_ballot_zip"},
                
                'abr_delivery_address_type1': {options: ["Off", "On"]},
                "abr_id_selections": {
                  options: [
                    "abr_ssn_number",
                    "abr_drivers_license",
                    "abr_id_no2",
                  ]
                },
                'abr_id_type1': {},
                'abr_id_type2': {},
                'abr_id_no2': {options: ["Off", "On"], method: "abr_id_selections_is_no2"},                
                'abr_date_of_birth_mm_dd_yyyy': {
                  method: "date_of_birth_mm_dd_yyyy",
                  pdf_name: "date_of_birth_mm_dd_yyyy"
                },
                
                'abr_id_type_3': {},
                
                "abr_election_type1": {options: ["Off", "On"]},
                "abr_election_type2": {options: ["Off", "On"]},
                "abr_election_type3": {options: ["Off", "On"]},
                "abr_election_type4": {options: ["Off", "On"]},
                "abr_election_type5": {options: ["Off", "On"]},

                'abr_party_selections_input': {
                  options: [
                    "abr_party1",
                    "abr_party2",
                    "abr_party3",
                    "abr_party4",
                    "abr_party5",
                  ],
                },
                'abr_party_selections': {
                  method: "abr_party_selections_string"
                },
                 
               }
  
  EXTRA_FIELDS = ["abr_previous_name_check", "abr_party_selections_input", "abr_check_mailing_address", "abr_id_selections",
    "abr_mailing_address_line_1_input",
    "abr_mailing_unit_input",
    "abr_mailing_city_input",
    "abr_mailing_state_abbrev_input",
    "abr_mailing_zip_input",
  ]

  def form_field_items
    [
      {'abr_previous_name_check': {type: :checkbox}},
      {'abr_previous_full_name': {required: :if_visible, visible: "abr_previous_name_check"}},
      {'abr_citizen_selections': {type: :radio, required: true}},
      {'abr_18years_selections': {type: :radio, required: true}},
      {'abr_check_mailing_address': {type: :checkbox}},
      {'abr_mailing_address_instructions': {type: :instructions, visible: "abr_check_mailing_address"}},
      {'abr_mailing_address_line_1_input': {classes: "three-quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      {'abr_mailing_unit_input': {classes: "quarter", required: false, visible: "abr_check_mailing_address"}},
      {'abr_mailing_city_input': {classes: "half", required: :if_visible, visible: "abr_check_mailing_address"}},
      {'abr_mailing_state_abbrev_input': {type: :select, options: GeoState.collection_for_select, classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      {'abr_mailing_zip_input': {classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      
      {'abr_delivery_address_type1': {type: :checkbox}},
      {"abr_id_selections": {type: :radio, required: true}},
      {'abr_id_type1': {visible: "abr_id_selections_abr_ssn_number", required: :if_visible}},
      {'abr_id_type2': {visible: "abr_id_selections_abr_drivers_license", required: :if_visible}},
      
      {'abr_id_type_3': {}},
      {"abr_election_type_selections1": {type: :instructions}},
      {"abr_election_type_selections2": {type: :instructions}},
      {"abr_election_type1": {type: :checkbox}},
      {"abr_election_type2": {type: :checkbox}},
      {"abr_election_type3": {type: :checkbox}},
      {"abr_election_type4": {type: :checkbox}},
      {"abr_election_type5": {type: :checkbox}},

      {'abr_party_selections_input': {type: :radio, required: true}},
    ]
  end
  
  def custom_form_field_validations
    if self.abr_election_type1 != "1" &&
       self.abr_election_type2 != "1" &&
       self.abr_election_type3 != "1" &&
       self.abr_election_type4 != "1" &&
       self.abr_election_type5 != "1"
       errors.add(:abr_election_type1, custom_required_message(:abr_election_type1))
       errors.add(:abr_election_type2, custom_required_message(:abr_election_type1))
       errors.add(:abr_election_type3, custom_required_message(:abr_election_type1))
       errors.add(:abr_election_type4, custom_required_message(:abr_election_type1))
       errors.add(:abr_election_type5, custom_required_message(:abr_election_type1))
    end
  end

  def abr_id_selections_is_no2
    self.abr_id_selections == "abr_id_no2" ? "On" : "Off"
  end

  def abr_party_selections_string
    if self.abr_party_selections_input == "abr_party1"
      return "Alaska Democratic Party"
    end
    if self.abr_party_selections_input == "abr_party2"
      return "Alaska Republican Party"      
    end
    if self.abr_party_selections_input == "abr_party3"
      return "Alaskan Independence Party"      
    end
    if self.abr_party_selections_input == "abr_party4"
      return "Nonpartisan"      
    end
    if self.abr_party_selections_input == "abr_party5"
      return "Undeclared"      
    end
    return ""
  end
  
  def abr_ballot_address
    if self.abr_check_mailing_address == "1"
      return self.abr_mailing_address_line_1_input
    else
      return self.address_line_1
    end
  end
  def abr_ballot_unit
    if self.abr_check_mailing_address == "1"
      return self.abr_mailing_unit_input
    else
      return self.unit
    end
  end
  def abr_ballot_city
    if self.abr_check_mailing_address == "1"
      return self.abr_mailing_city_input
    else
      return self.city
    end
  end
  def abr_ballot_state_abbrev
    if self.abr_check_mailing_address == "1"
      return self.abr_mailing_state_abbrev_input
    else
      return "AK"
    end
  end
  def abr_ballot_zip
    if self.abr_check_mailing_address == "1"
      return self.abr_mailing_zip_input
    else
      return self.zip
    end
  end


end
