module AbrStateMethods::MO
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_initial": {method: "middle_initial"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_street_number": {method: "street_number"},	
    "abr_street_name": {method: "street_name"},	
    "abr_unit": {method: "unit"},	
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    "abr_zip": {method: "zip"},	
    
    
    "abr_last_4_ssn": {sensitive: true},	
    "abr_check_mailing_address": {},	
    "abr_mailing_address_line_1": {},	
    "abr_mailing_unit": {},	
    "abr_mailing_city": {},	
    "abr_mailing_state_abbrev": {},	
    "abr_mailing_zip": {},	
    "abr_reason_selections": {
      options: [
        "abr_reason1",
        "abr_reason2",
        "abr_reason3",
        "abr_reason4",
        "abr_reason5",
        "abr_reason6",
      ]
    },
    "abr_election_type_selections": {
      options: [
        "abr_election_type1",
        "abr_election_type2",
        "abr_election_type3",
      ]
    },	
    "abr_election_date": {
      method: "abr_election_date_input_string"
    },
    
    "abr_primary_type_selections1": {
      method: "abr_primary_type_selections_string"
    },

    "abr_primary_type_selections": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3",
        "abr_primary_type4",
        "abr_primary_type5",
      ]
    },	
  }

  EXTRA_FIELDS = ["abr_election_date_input_dd", "abr_election_date_input_mm", "abr_election_date_input_yyyy"]
  
  def form_field_items
    [
      {"abr_last_4_ssn": {required: true, regexp: /\A\d{4}\z/}},	
      {"abr_check_mailing_address": {type: :checkbox}},	
      {"abr_mailing_address_instructions": {type: :instructions}},
      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      
      {"abr_reason_selections": { type: :radio, required: true }},
      {"abr_election_type_selections_instructions": {type: :instructions}},
      {"abr_election_type_selections": { type: :radio, required: true}},
      {"abr_election_date_input": { type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type3" }},
      {"abr_primary_type_selections": { type: :radio, required: :if_visible, visible: "abr_election_type_selections_abr_election_type1" }},
    ]
  end
  
  def abr_election_date_input_string
    if self.abr_election_type_selections == "abr_election_type1"
      "08/02/2022"
    elsif self.abr_election_type_selections == "abr_election_type2"
      "11/08/2022"
    else
      date_field_string_mm_dd_yyyy(method: :abr_election_date_input)
    end
  end

  def abr_primary_type_selections_string
    v = self.abr_primary_type_selections
    return "Republican" if v =="abr_primary_type1"
    return "Democrat" if v ==    "abr_primary_type2"
    return "Libertarian" if v ==    "abr_primary_type3"
    return "Constitution" if v ==    "abr_primary_type4"
    return "Issues only" if v ==     "abr_primary_type5"
  end
  
  def custom_form_field_validations

  end
  
 
end