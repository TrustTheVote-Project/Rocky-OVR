module AbrStateMethods::MN
  
    PDF_FIELDS = {

        # Last name or surname
        "Last name or surname": {
            method: 'last_name',
        },
        # First name
        "First name": {
            method: 'first_name',
        },
        # Middle name
        "Middle name": {
            method: 'middle_name',
        },
        # Suffix
        "Suffix": {
            method: 'name_suffix',
        },

        # Date of Birth
        "Date of Birth":{
            method: 'date_of_birth_mm_dd_yyyy',
        },

        # County where you live
        "County where you live": {},
        # Phone Number
        "Phone Number":{
            method: 'phone',
        },
        # Email Address
        "Email Address": {
            method: 'email',
        },


        # I have a Minnesota-issued driver's license or ID Card
        "I have a Minnesota-issued driver's license or ID Card": { options: ["Off", "On"],
        method: "check_dln_check_on" },

        # Minnesota Driver's License or ID Card Number
        "Minnesota Driver's License or ID Card Number": { sensitive: true},


        # I have a Social Security Number
        "I have a Social Security Number": { options: ["Off", "On"],
        method: "check_ss_check_on" },

        # Last four digits of Social Security Number
        "Last four digits of Social Security Number": {sensitive: true},


        # Do not have a Minnesota-issued driver's license or identification card, or a Social Security Number
        "Do not have a Minnesota-issued driver's license or identification card, or a Social Security Number": { options: ["Off", "On"],
        method: "check_no_id_check_on" },

        # Residential address - House number, Street &amp; Apartment
        "Residential address_1": {
            method: 'address'
        },
        # Residential address - City
        "Residential address - City": {
            method: 'city'
        },
        # Residential address - Zip Code
        "Residential address - Zip Code": {
            method: 'zip'
        },
        
        # Absentee ballot address - House number, Street &amp; Apartment
        "Absentee ballot address_1": {},
        # Absentee ballot address - City
        "Absentee ballot address - City": {},
        # Absentee ballot address - State
        "Absentee ballot address - State": {},
        # Absentee ballot address - Zip Code
        "Absentee ballot address - Zip Code": {},


        # Absentee ballot requested for other election, specify date
        "Absentee ballot requested for other election, specify date": { options: ["Off", "On"], value: 'Off' },

        # Absentee ballot requested for 2/11 special election
        "Absentee ballot requested for 2/11 special election": { options: ["Off", "On"], value: 'Off' },

        # Absentee ballot requested for 3/10 township election
        "Absentee ballot requested for 3/10 township election": { options: ["Off", "On"], value: 'Off' },

        # Absentee ballot requested for 4/14 special election
        "Absentee ballot requested for 4/14 special election": { options: ["Off", "On"], value: 'Off' },

        # Absentee ballot requested for 5/12 special election
        "Absentee ballot requested for 5/12 special election": { options: ["Off", "On"], value: 'Off' },


        # Absentee ballot requested for 8/11 primary only
        "Absentee ballot requested for 8/11 primary only": { options: ["Off", "On"], value: 'Off' },


        # Absentee ballot requested for 11/3 general election only
        "Absentee ballot requested for 11/3 general election only": { 
            options: ["Off", "On"],
            value: "On"
        },


        # Absentee ballot requested for both 8/11 primary and 11/3 general elections
        "Absentee ballot requested for both 8/11 primary and 11/3 general elections": { options: ["Off", "On"], value: 'Off' },

        # Special Election Date
        "Special Election Date": {},






        # 
       # "voter_signature": {}

        # 
        #"date_signed": {}

    }
    #EXTRA_FIELDS = []
    # e.g.
    EXTRA_FIELDS = ["has_mailing_address", "dln_check", 'ss_check', 'no_id_check','id_instruction','id_instruction_subhead']
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [
        {"County where you live": {type: :select, required: true, include_blank: true, options: [
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

            {'id_instruction': {type: :instructions}},
            {"dln_check": {
                type: :checkbox,
                classes: "indent"
            }},

            # Minnesota Driver's License or ID Card Number
            {"Minnesota Driver's License or ID Card Number": { 
                visible: 'dln_check',
                required: :if_visible,
                regexp: /\A[[:alpha:]]\d{12}\z/,
                length: 13,
                classes: "indent"}},

            {"ss_check": {
                type: :checkbox,
                classes: "indent"
            }},

            {"Last four digits of Social Security Number": { 
                visible: 'ss_check',
                required: :if_visible,
                length:4,
                regexp: /\A\d{4}\z/,
                classes: "indent"}},
            
            {"no_id_check": {
                type: :checkbox,
                classes: "indent"
            }},


        {"has_mailing_address": {type: :checkbox}},

        {"Absentee ballot address_1": {visible: "has_mailing_address", required: :if_visible}},
        {"Absentee ballot address - City": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
        {"Absentee ballot address - State": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"Absentee ballot address - Zip Code": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last", min:5}},
  





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
    
    
    def check_dln_check_on
        return("On") if self.dln_check.to_s=='1'
    end

    def check_ss_check_on
        return("On") if self.ss_check.to_s=='1'
    end

    def check_no_id_check_on
        return("On") if self.no_id_check.to_s=='1'
    end

    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery

      if ((self.dln_check.to_s=='1' || self.ss_check.to_s=='1') && (self.no_id_check.to_s=='1'))
        errors.add('no_id_check', custom_format_message('no_id_check'))
      end
 
      if ((self.dln_check.to_s!='1' && self.ss_check.to_s!='1') && (self.no_id_check.to_s!='1'))
        errors.add('no_id_check', custom_required_message('no_id_check'))
      end
      
    end
    
   
  end