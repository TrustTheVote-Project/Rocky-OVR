module AbrStateMethods::VT
  
    PDF_FIELDS = {
      "abr_email": {method: "email"},	
      "abr_phone": {method: "phone"},	
      "abr_first_name": {method: "first_name"},	
      "abr_middle_name": {method: "middle_name"},	
      "abr_last_name": {method: "last_name"},	
      "abr_name_suffix": {method: "name_suffix"},	
      "abr_street_number":{method: "street_number"},
      "abr_street_name":{method: "street_name"},
      "abr_unit":{method: "unit"},
      "abr_city": {method: "city"},	
      "abr_home_state_name": {method: "home_state_abbrev"},	
      "abr_home_state_abbrev": {method: "home_state_abbrev"},	
      "abr_zip": {method: "zip"},	
      #'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },
  
  
      
'abr_previous_name_check':{},
'abr_previous_full_name':{},
'abr_delivery_address_selections':{options: ["abr_delivery_address_type1", "abr_delivery_address_type2"]},
'abr_delivery_address_type2':{method: "same_as_residence"},

'abr_mailing_address_instructions':{},
'abr_mailing_address_line_1':{},
'abr_mailing_unit':{},
'abr_mailing_city':{},
'abr_mailing_state_abbrev':{},
'abr_mailing_zip':{},
'abr_election_type_selections':{options: ["abr_election_type1", "abr_election_type2"]},

'abr_election_type_instructions':{},
'abr_election_type3':{options:["Off","On" ]},
'abr_election_type4':{options:["Off","On" ]},
'abr_election_type5':{options:["Off","On" ]},
'abr_election_type6':{options:["Off","On" ]},
'abr_election_type7':{options:["Off","On" ]},
'abr_primary_type_selections':{options: ["abr_primary_type1", "abr_primary_type2"]},
"abr_primary_type_selections_1": {method: "abr_primary_type_selections"},

'abr_absence_begin_date':{method: "absence_begin_date_string"},
'abr_absence_end_date':{method: "absence_end_date_string"},
'abr_request_check':{},
'abr_request_instructions':{},
'abr_request_name':{},
'abr_request_name2':{},
'abr_assistant_address_line_1':{},
'abr_assistant_address_line2':{},
'abr_assistant_phone':{},
'abr_request_selections':{options: ["abr_request_type1","abr_request_type2","abr_request_type3"]},


          }
  
    EXTRA_FIELDS = ["abr_absence_begin_date_input_dd", "abr_absence_begin_date_input_mm",  "abr_absence_begin_date_input_yyyy",
        "abr_absence_end_date_input_dd", "abr_absence_end_date_input_mm", "abr_absence_end_date_input_yyyy"]
    # e.g.
    # EXTRA_FIELDS = ["has_mailing_address", "identification"]
    
    def form_field_items
      [
        {'abr_previous_name_check': {type: :checkbox}},
        {'abr_previous_full_name': {visible: "abr_previous_name_check", required: :if_visible}},
        
      
        {"abr_delivery_address_selections": {type: :radio, options:["abr_delivery_address_type1","abr_delivery_address_type2"], required: true}},	
        
        {"abr_mailing_address_instructions": {type: :instructions,  visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},
        {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},	
        {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},	
        {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},	
        {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},	
        {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_delivery_address_selections_abr_delivery_address_type1"}},	
  

        {"abr_election_type_selections": {type: :radio, options: ["abr_election_type1", "abr_election_type2"], required: true}},

        {"abr_election_type_instructions": {type: :instructions, visible: "abr_election_type_selections_abr_election_type1"}},
        {"abr_election_type3": {type: :checkbox, visible: "abr_election_type_selections_abr_election_type1", options:["Off","On" ]}},
        {"abr_election_type4": {type: :checkbox, visible: "abr_election_type_selections_abr_election_type1", options:["Off","On" ]}},
        {"abr_election_type5": {type: :checkbox, visible: "abr_election_type_selections_abr_election_type1", options:["Off","On" ]}},
        {"abr_election_type6": {type: :checkbox, visible: "abr_election_type_selections_abr_election_type1", options:["Off","On" ]}},
        {"abr_election_type7": {type: :checkbox, visible: "abr_election_type_selections_abr_election_type1", options:["Off","On" ]}},

        {"abr_primary_type_selections": {type: :radio, visible:"abr_election_type7", required: :if_visible,  options: ["abr_primary_type1", "abr_primary_type2"]}},

        



        {'abr_absence_begin_date_input':{type: :date, visible: "abr_election_type_selections_abr_election_type2", required: :if_visible}},
        {'abr_absence_end_date_input':{type: :date, visible: "abr_election_type_selections_abr_election_type2", required: :if_visible}},
  
        {'abr_request_check':{ type: :checkbox}},
        {'abr_request_instructions':{type: :instructions, visible:"abr_request_check" }},
        {'abr_request_name':{visible:"abr_request_check", required: :if_visible }},
        {'abr_request_name2':{visible:"abr_request_check" }},
        {'abr_assistant_address_line_1':{visible:"abr_request_check", required: :if_visible }},
        {'abr_assistant_address_line2':{visible:"abr_request_check", required: :if_visible }},
        {'abr_assistant_phone':{visible:"abr_request_check", required: :if_visible }},
        {'abr_request_selections':{type: :radio, visible:"abr_request_check", required: :if_visible, options: ["abr_request_type1","abr_request_type2","abr_request_type3"] }},


      ]
    end
    
    def custom_form_field_validations
        if self.abr_election_type_selections == "abr_election_type1"
            
                unless self.abr_election_type3=="1" || self.abr_election_type4 =="1" || self.abr_election_type5 =="1" || self.abr_election_type6 =="1" || self.abr_election_type7 =="1"
                    errors.add('abr_election_type7', custom_required_message('abr_no_election_checked'))
                end
        end
    end
    
    def same_as_residence
        return "On" if self.abr_delivery_address_selections == "abr_delivery_address_type2"
    end

    def absence_begin_date_string
        date_field_string_mm_dd_yyyy(method: :abr_absence_begin_date_input)
    end

    def absence_end_date_string
        date_field_string_mm_dd_yyyy(method: :abr_absence_end_date_input)
    end
   
  end
  