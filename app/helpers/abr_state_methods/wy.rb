module AbrStateMethods::WY

  PDF_FIELDS = {

  "abr_email": {method: "email"},	
  "abr_phone": {method: "phone"},	
  "abr_first_name": {method: "first_name"},	
  "abr_middle_name": {method: "middle_name"},	
  "abr_last_name": {method: "last_name"},	
  "abr_name_suffix": {method: "name_suffix"},	
  "abr_street_number": {method: "street_number"},	
  "abr_street_name": {method: "street_name"},	
  "abr_unit": {method: "unit"},	
  "abr_city": {method: "city"},	
  "abr_home_state_abbrev": {method: "home_state_abbrev"},	
  "abr_zip": {method: "zip"},	
  'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },
  


  "abr_check_mailing_address":{},
  "abr_mailing_address_line_1":{},
  "abr_mailing_unit":{},
  "abr_mailing_city":{},
  "abr_mailing_state_abbrev":{},
  "abr_mailing_zip":{},

  "abr_uocava_check":{ method: "abr_uocava_check_y_n"},

  "abr_election_type1":{ method: "abr_election_type1_check_on"},
  "abr_election_type2":{ method: "abr_election_type2_check_on"},
  "abr_party":{},
  "abr_request_check":{},
  "abr_request_name":{},
  }


  # def signature_pdf_field_name
  #   "voter_signature"
  # end

  EXTRA_FIELDS = ["abr_election_type1_check", "abr_election_type2_check"]
  
  def form_field_items
    [

      {"abr_check_mailing_address": {type: :checkbox}},	
      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	


      {"abr_election_type_selections": {type: :instructions }},
      {"abr_election_type1_check": { type: :checkbox}},
      {"abr_election_type2_check": { type: :checkbox}},

      {"abr_party": {visible: "abr_election_type1_check", required: :if_visible}},

      {"abr_uocava_check": {required: true, type: :radio, options: ["Yes", "No"]}},
      {"abr_request_check": {type: :checkbox}},
      {"abr_request_name": {visible: "abr_request_check", required: :if_visible}}
    ]
  end

  def custom_form_field_validations
    if  self.abr_election_type1_check == "0" && self.abr_election_type2_check == "0" 
      #errors.add("abr_election_type1", custom_required_message("no_election_type") )
      errors.add("abr_election_type2_check", custom_required_message("no_election_type") )
    end

  end

  def abr_election_type1_check_on
    return "On" if abr_election_type1_check=="1"
  end
  def abr_election_type2_check_on
    return "On" if abr_election_type2_check=="1"
  end

  

  
  
end
