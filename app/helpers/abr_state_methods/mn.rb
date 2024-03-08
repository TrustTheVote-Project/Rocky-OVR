module AbrStateMethods::MN
  
    PDF_FIELDS = {
      "abr_email": {method: "email"},	
      "abr_phone": {method: "phone"},	
      "abr_first_name": {method: "first_name"},	
      'abr_middle_name': {:method=>"middle_name"},
      "abr_last_name": {method: "last_name"},	
      "abr_name_suffix": {method: "name_suffix"},	
      "abr_street_number": {method: "street_number"},	
      "abr_street_name": {method: "street_name"},
      "abr_unit": {method: "unit"},	
      "abr_city": {method: "city"},	
      'abr_zip': {method: "zip"},
      'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },     

      'abr_check_mailing_address':{},
      'abr_mailing_address_line_1': {method: "mailing_address_line_1"},
      'abr_mailing_unit': {method: "mailing_unit"},
      'abr_mailing_city':{method: "mailing_city"},
      'abr_mailing_state_abbrev':{method: "mailing_state_abbrev"},
      'abr_mailing_zip':{method: "mailing_zip"},   
     

      'abr_county': {},
                  'abr_id_type1': {options:["Off","On" ]},
                  'abr_id_type2': {options:["Off","On" ]},
                  'abr_no_id': {options:["Off","On" ]},
                  'abr_drivers_license': {},
                  'abr_ssn_number': {},
                  'abr_election_type1': {options:["Off","On" ]},
                  'abr_election_type2':{options:["Off","On" ]},
                  'abr_election_type3': {options:["Off","On" ]},
                  'abr_election_type4': {options:["Off","On" ]},
                  'abr_election_type5': {options:["Off","On" ]},
                  'abr_election_type6': {options:["Off","On" ]},
                  'abr_election_date': {method: "abr_election_date_string"},

    }


    #EXTRA_FIELDS = []
    # e.g.
    EXTRA_FIELDS = ["abr_election_date_input_dd", "abr_election_date_input_mm", "abr_election_date_input_yyyy",
      "abr_mailing_address_line_1_input",
      "abr_mailing_unit_input",
      "abr_mailing_city_input",
      "abr_mailing_state_abbrev_input",
      "abr_mailing_zip_input",
    ]
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [
        {"abr_election_type_selections": {type: :instructions}},
        {"abr_election_type1": {type: :checkbox, options:["Off","On" ],}},	
        {"abr_election_type2": {type: :checkbox, options:["Off","On" ],}},	
        {"abr_election_type3": {type: :checkbox, options:["Off","On" ],}},	
        {"abr_election_type4": {type: :checkbox, options:["Off","On" ],}},
        {"abr_election_type5": {type: :checkbox, options:["Off","On" ],}},
        {"abr_election_type6": {type: :checkbox, options:["Off","On" ],}},        
        {"abr_election_date_input": {type: :date, visible: "abr_election_type6", required: :if_visible}},

        {"abr_id_instructions": {type: :instructions}},
        {"abr_id_type1": {type: :checkbox, options:["Off","On" ],}},	
        {"abr_drivers_license":{ visible: "abr_id_type1", required: :if_visible}},	
        {"abr_id_type2": {type: :checkbox, options:["Off","On" ],}},	
        {"abr_ssn_number": {length:4, min: 4, max: 4, visible: "abr_id_type2", required: :if_visible}},	
        {"abr_no_id": {hidden_any: ["abr_id_type1", "abr_type_2"], type: :checkbox, options:["Off","On" ],}},	


        {"abr_county": {type: :select, required: true, include_blank: true, options: [
            'Aitkin',
            'Anoka',
            'Becker',
            'Beltrami',
            'Benton',
            'Big Stone',
            'Blue Earth',
            'Brown',
            'Carlton',
            'Carver',
            'Cass',
            'Chippewa',
            'Chisago',
            'Clay',
            'Clearwater',
            'Cook', 
            'Cottonwood',
            'Crow Wing',
            'Dakota',
            'Dodge',
            'Douglas',
            'Faribault',
            'Fillmore',
            'Freeborn',
            'Goodhue',
            'Grant',
            'Hennepin',
            'Houston',
            'Hubbard',
            'Isanti',
            'Itasca',
            'Jackson',
            'Kanabec',
            'Kandiyohi',
            'Kittson',
            'Koochiching',
            'Lac Qui Parle',
            'Lake',
            'Lake Of The Wood',
            'Le Sueur',
            'Lincoln',
            'Lyon',
            'Mahnomen',
            'Marshall',
            'Martin',
            'McLeod',
            'Meeker',
            'Mille Lacs',
            'Morrison',
            'Mower',
            'Murray',
            'Nicollet',
            'Nobles',
            'Norman',
            'Olmsted',
            'Otter Tail',
            'Pennington',
            'Pine',
            'Pipestone',
            'Polk',
            'Pope',
            'Ramsey',
            'Red Lake',
            'Redwood',
            'Renville',
            'Rice',
            'Rock',
            'Roseau',
            'St. Louis',
            'Scott',
            'Sherburne',
            'Sibley',
            'Stearns',
            'Steele',
            'Stevens',
            'Swift',
            'Todd',
            'Traverse',
            'Wabasha',
            'Wadena',
            'Waseca',
            'Washington',
            'Watonwan',
            'Wilkin',
            'Winona',
            'Wright',
            'Yellow Medicine']}},

            {"abr_check_mailing_address": {type: :checkbox}},	
            {"abr_mailing_address_instructions": {type: :instructions, visible: "abr_check_mailing_address"}},
            {"abr_mailing_address_line_1_input": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
            {"abr_mailing_unit_input": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
            {"abr_mailing_city_input": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
            {"abr_mailing_state_abbrev_input": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
            {"abr_mailing_zip_input": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

        #     {'id_instruction': {type: :instructions}},
        #     {"dln_check": {
        #         type: :checkbox,
        #         classes: "indent"
        #     }},

        #     # Minnesota Driver's License or ID Card Number
        #     {"Minnesota Driver's License or ID Card Number": { 
        #         visible: 'dln_check',
        #         required: :if_visible,
        #         regexp: /\A[[:alpha:]]\d{12}\z/,
        #         length: 13,
        #         classes: "indent"}},

        #     {"ss_check": {
        #         type: :checkbox,
        #         classes: "indent"
        #     }},

        #     {"Last four digits of Social Security Number": { 
        #         visible: 'ss_check',
        #         required: :if_visible,
        #         length:4,
        #         regexp: /\A\d{4}\z/,
        #         classes: "indent"}},
            
        #     {"no_id_check": {DNU
        #         type: :checkbox,
        #         classes: "indent"
        #     }},


        # {"has_mailing_address": {type: :checkbox}},

        # {"Absentee ballot address_1": {visible: "has_mailing_address", required: :if_visible}},
        # {"Absentee ballot address - City": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
        # {"Absentee ballot address - State": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select}},
        # {"Absentee ballot address - Zip Code": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last", min:5}},
  





      ]
    end
    #e.g.
    # [
    #   {"reason_instructions": {type: :instructions}}, *"reason_instructions" does NOT get put into EXTRA_FIELDS
    #   {"County": {type: :select, required: true, include_blank: true, options: [
    #     "Adams",
    #   ]}},
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
    
    
    # def check_dln_check_on
    #     return("On") if self.dln_check.to_s=='1'
    # end

    # def check_ss_check_on
    #     return("On") if self.ss_check.to_s=='1'
    # end

    # def check_no_id_check_on
    #     return("On") if self.no_id_check.to_s=='1'
    # end

    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery

 
      if ((self.abr_id_type1.to_s!='1' && self.abr_id_type2.to_s!='1') && (self.abr_no_id.to_s!='1'))
        errors.add('abr_no_id', custom_required_message('no_id_check'))
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

    def abr_election_date_string
      date_field_string_mm_dd_yy(method: :abr_election_date_input)
    end

    
   
  end