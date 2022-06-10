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
    "abr_mailing_address_line_1": {
      method: "mailing_address_line_1"
    },	
    "abr_mailing_unit": {
      method: "mailing_unit"
    },	
    "abr_mailing_city": {
      method: "mailing_city"
    },	
    "abr_mailing_state_abbrev": {
      method: "mailing_state_abbrev"
    },	
    "abr_mailing_zip": {
      method: "mailing_zip"
    },	
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

  EXTRA_FIELDS = ["abr_election_date_input_dd", "abr_election_date_input_mm", "abr_election_date_input_yyyy",
    "abr_mailing_address_line_1_input",
    "abr_mailing_unit_input",
    "abr_mailing_city_input",
    "abr_mailing_state_abbrev_input",
    "abr_mailing_zip_input",
  ]
  
  def form_field_items
    [
      {"abr_last_4_ssn": {required: true, regexp: /\A\d{4}\z/}},	
      {"abr_check_mailing_address": {type: :checkbox}},	
      {"abr_mailing_address_instructions": {type: :instructions}},
      {"abr_mailing_address_line_1_input": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit_input": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city_input": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev_input": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip_input": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      
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
    if self.phone.blank?
      errors.add(:phone, :blank)
    end
  end
  

  def mailing_address_line_1
    self.abr_check_mailing_address.to_s == "1" ? self.abr_mailing_address_line_1_input : self.address_line_1
  end
  def mailing_unit
    self.abr_check_mailing_address.to_s == "1" ? self.abr_mailing_unit_input : self.unit
  end
  def mailing_city
    self.abr_check_mailing_address.to_s == "1" ? self.abr_mailing_city_input : self.city
  end

  def mailing_state_abbrev
    self.abr_check_mailing_address.to_s == "1" ? self.abr_mailing_state_abbrev_input : self.home_state_abbrev
  end
  def mailing_zip
    self.abr_check_mailing_address.to_s == "1" ? self.abr_mailing_zip_input : self.zip
  end
 
end