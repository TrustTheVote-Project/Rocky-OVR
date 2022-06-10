module AbrStateMethods::MD
  
  PDF_FIELDS = {'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {method: 'middle_name'},
                'abr_last_name': {:method=>"last_name"},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_phone': {method: "phone"},
                'abr_email': {method: "email"},
                'abr_date_of_birth_mm_dd_yyyy': {
                  pdf_name: 'date_of_birth_mm_dd_yyyy',
                  method: 'date_of_birth_mm_dd_yyyy'
                },
                'abr_street_number': {method: 'street_number'},
                'abr_street_name': {method: 'street_name'},
                'abr_unit': {:method=>"unit"},

                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                
                'abr_address_type5': {
                  method: "mailing_delivery_selected"
                },
                'abr_delivery_email': { method: "email_for_delivery"},


                'abr_address_type_selections': {
                  options: [
                    "abr_address_type1",
                    "abr_address_type2",
                    "abr_address_type3",
                    "abr_address_type4",
                  ]
                },
                'abr_fax_number': {},
                "abr_id_selections": {
                  options: [
                    "abr_id_type1",
                    "abr_id_type2",
                  ]
                },
                'abr_drivers_license': { sensitive: true },
                'abr_id_date': {sensitive: true, method: "abr_id_date_string"},
                'abr_last_4_ssn': {sensitive: true},
                
                'abr_mailing_address_line_1': {},
                'abr_mailing_unit': {},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_zip': {},
                'abr_election_type_selections': {
                  options: [
                    "abr_election_type1",
                    "abr_election_type2",
                    "abr_election_type3",
                    "abr_election_type4",                    
                  ]
                },
                'abr_primary_type_selections': {
                  options: [
                    "abr_primary_type1",
                    "abr_primary_type2",
                    "abr_primary_type3",
                    "abr_primary_type4",
                    "abr_primary_type5",
                    "abr_primary_type6",
                    "abr_primary_type7",                    
                  ]
                },
                'abr_primary_type7_name': {},
                'abr_contact_method_selections': {
                  options: [
                    "abr_contact_method1",
                    "abr_contact_method2",
                    "abr_contact_method3",
                  ]
                },
}
    EXTRA_FIELDS = ["abr_id_date_input_mm", "abr_id_date_input_dd", "abr_id_date_input_yyyy"]
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [
        {'abr_address_type_selections': {type: :radio, required: true}},
        {'abr_fax_number': {required: :if_visible, visible: "abr_address_type_selections_abr_address_type4"}},
        {"abr_id_selections": {type: :radio, required: :if_visible, visible: "abr_address_type_selections_abr_address_type3" }},
        {'abr_drivers_license': {required: :if_visible, visible: "abr_id_selections_abr_id_type1", regexp: /\A[a-zA-Z]\d{12}\z/ }},
        {'abr_id_date_input': {type: :date, required: :if_visible, visible: "abr_id_selections_abr_id_type1",}},
        {'abr_last_4_ssn': {required: :if_visible, visible: "abr_id_selections_abr_id_type2", regexp: /\A\d{4}\z/}}, 
        {'abr_mailing_address_instructions': {type: :instructions, visible: 'abr_address_type_selections_abr_address_type2'}},
        {'abr_mailing_address_line_1': {classes: 'three-quarter', required: :if_visible, visible: "abr_address_type_selections_abr_address_type2"}},
        {'abr_mailing_unit': {classes: 'quarter', visible: "abr_address_type_selections_abr_address_type2"}},
        {'abr_mailing_city': {classes: 'half', required: :if_visible, visible: "abr_address_type_selections_abr_address_type2"}},
        {'abr_mailing_state_abbrev': {classes: 'quarter', type: :select, required: :if_visible, visible: "abr_address_type_selections_abr_address_type2", options: GeoState.collection_for_select}},
        {'abr_mailing_zip': {classes: 'quarter', required: :if_visible, visible: "abr_address_type_selections_abr_address_type2"}},
        {'abr_election_type_selections': { type: :radio, required: true}},
        {'abr_primary_type_selections': { type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type_selections_abr_election_type2 abr_election_type_selections_abr_election_type3"}},
        {'abr_primary_type7_name': {required: :if_visible, visible: "abr_primary_type_selections_abr_primary_type7"}},
        {'abr_contact_method_selections': { type: :radio, required: true }},

      ]
    end

    def abr_id_date_string
      date_field_string_mm_dd_yyyy(method: :abr_id_date_input)
    end

    def mailing_delivery_selected
      if abr_address_type_selections_abr_address_type1 || abr_address_type_selections_abr_address_type2
        return "abr_address_type5"
      end
      return nil
    end

    def email_for_delivery
      if abr_address_type_selections_abr_address_type3
        return self.email
      else
        return nil
      end
    end
    
    def custom_form_field_validations
      if self.abr_contact_method_selections == "abr_contact_method1" && self.phone.blank?
        errors.add(:phone, :required_if_opt_in)
      end

    end
   
   
  end
  
