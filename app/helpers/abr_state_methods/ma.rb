module AbrStateMethods::MA
  

  PDF_FIELDS = {
  
    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    'abr_middle_initial': {:method=>"middle_initial"},
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_street_number": {method: "street_number"},	
    "abr_street_name": {method: "street_name"},
    "abr_unit": {method: "unit"},	
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    'abr_zip': {method: "zip"},
   # "abr_full_name": {method:"full_name"},
    'date_of_birth_mm_dd_yyyy':{},     
    
    'abr_check_mailing_address':{options: ["Off", "On"]},

    'abr_mailing_address_line_1': {},
    'abr_mailing_unit': {},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip': {},  

    'abr_election_type_selections': {method: 'abr_election_type_selections_value', options: ['abr_election_type1','abr_election_type2','abr_election_type3']},
    'abr_election_type_selections_input': {options: ['abr_election_type1','abr_election_typeprimary','abr_election_type2','abr_election_type3']},
    'abr_election_date': {method: "election_date_string"},
    "abr_primary_type1": {},
    #"abr_primary_type2": {},
    "abr_request_check": {options: ["Off", "On"]},
    "abr_relationship1": {},
    "abr_reason1": {options: ["Off", "On"]},
    "abr_reason2": {options: ["Off", "On"]},
    "abr_reason3": {options: ["Off", "On"]},
    "abr_reason4": {options: ["Off", "On"]},
    "abr_assistant_check1": {options: ["Off", "On"]},
    "abr_request_name": {},
    "abr_assistant_name": {},
    "abr_assistant_address_line_1": {},
    "abr_assistant_address_line2": {},



  }

 
  EXTRA_FIELDS = ["election_date_input","election_date_input_mm","election_date_input_dd","election_date_input_yyyy", ]

  def form_field_items
    [
      {"abr_check_mailing_address": {type: :checkbox}},	
      
      {"abr_mailing_address_instructions": {type: :instructions,  visible: "abr_check_mailing_address"}},
      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

      {'abr_election_type_selections_input': {type: :radio, required: true}},
      {'election_date_input': {type: :date, visible: "abr_election_type_selections_input_abr_election_type3", required: :if_visible}},
      {'abr_primary_type_instructions': {type: :instructions, visible_any:"abr_election_type_selections_input_abr_election_type1 abr_election_type_selections_input_abr_election_typeprimary" }},
      {"abr_primary_type1": { visible_any:"abr_election_type_selections_input_abr_election_type1 abr_election_type_selections_input_abr_election_typeprimary"}},
      #{"abr_primary_type2": { visible_any:"abr_election_type_selections_abr_election_type1 abr_election_type_selections_abr_election_type3", required: :if_visible}},
      {"abr_request_check": {type: :checkbox}},
      {"abr_relationship1": {visible: "abr_request_check", required: :if_visible }},
      {"abr_reason1": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_reason2": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_reason3": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_reason4": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_request_name": {visible: "abr_reason4", required: :if_visible}},
      {"abr_assistant_check1": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_assistant_name": {visible: "abr_assistant_check1", required: :if_visible}},
      {"abr_assistant_address_line_1": {visible: "abr_assistant_check1", required: :if_visible}},
      {"abr_assistant_address_line2": {visible: "abr_assistant_check1"}},

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
    election_date =  self.date_field_value(method: :election_date_input)
    if  election_date &&  election_date < Date.today
      errors.add(:election_date_input, custom_format_message("election_date_input") )
    end

  end

  def abr_election_type_selections_value
    abr_election_type_selections_input == 'abr_election_typeprimary' ? 'abr_election_type3' : abr_election_type_selections_input
  end
  
  def election_date_string
    if abr_election_type_selections_input == 'abr_election_typeprimary'
      return "09/06/2022"
    end
    date_field_string_mm_dd_yyyy(method: :election_date_input)
  end
 
end