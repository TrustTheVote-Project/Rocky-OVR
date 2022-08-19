module AbrStateMethods::DE
  
  PDF_FIELDS = {

    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    'abr_middle_initial': {:method=>"middle_initial"},
    "abr_last_name": {method: "last_name"},	
 
    "abr_street_number": {method: "street_number"},	
    "abr_street_name": {method: "street_name"},
    "abr_unit": {method: "unit"},	
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    'abr_zip': {method: "zip"},
    'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },     

    'abr_last_4_ssn': {sensitive:true},

    'abr_check_mailing_address':{},
    'abr_mailing_address_line_1': {},
    'abr_mailing_unit': {},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip':{},   

    'abr_address_line_2':{},

    'abr_election_type_instructions': {},
    'abr_election_type_selections': {},
    'abr_election_type1': {options: ['Off', 'On']},
    'abr_election_type2': {options: ['Off', 'On']},
    'abr_election_type3': {options: ['Off', 'On']},
    'abr_election_type4': {options: ['Off', 'On']},
    'abr_party': {},
    'abr_delivery_address_selections': {options:['abr_delivery_address_type1','abr_delivery_address_type2','abr_delivery_address_type3']},
    'abr_fax_number': {},

   

  }
  
  EXTRA_FIELDS = []
  
  def form_field_items
    [
      {'abr_last_4_ssn':{min:4, max:4, required:true}},

      {"abr_check_mailing_address": {type: :checkbox, options: ["Off", "On"]}},	

      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

      {'abr_election_type_instructions': {type: :instructions}},
      {'abr_election_type_selections': {type: :instructions}},
      {'abr_election_type1': {type: :checkbox, options: ['Off', 'On']}},
      {'abr_election_type2': {type: :checkbox, options: ['Off', 'On']}},
      {'abr_election_type3': {type: :checkbox, options: ['Off', 'On']}},
      {'abr_election_type4': {type: :checkbox, options: ['Off', 'On']}},
      {'abr_party': {visible_any: "abr_election_type1,abr_election_type2,abr_election_type4", required: :if_visible}},
      

    
    ]
  end
  
  def custom_form_field_validations
    unless self.abr_election_type1.to_s == "1" || self.abr_election_type2.to_s =="1" || self.abr_election_type3.to_s =="1" || self.abr_election_type4.to_s =="1"
        errors.add "abr_election_type4", custom_required_message(:abr_election_type4)
    end

    if (self.abr_election_type1.to_s == "1" || self.abr_election_type2.to_s =="1" || self.abr_election_type4.to_s =="1")
      custom_validates_presence_of("abr_party")
    end

  end


  

end