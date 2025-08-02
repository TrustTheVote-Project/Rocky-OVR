module AbrStateMethods::VA

  PDF_FIELDS = {'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {method: "middle_name"},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_phone': {method: "phone"},
                'abr_email': {:method=>"email"},
                
                'abr_last_4_ssn': {sensitive: true},
                'abr_street_number': {method: "street_number"},
                'abr_street_name': {method: "street_name"},
                
                'abr_unit': {:method=>"unit"},
                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                
                'abr_election_type_selections': {},
                'abr_primary_type_selections1': {},
                'abr_election_type_selections2': {},
                'abr_election_date': {},
                'abr_county': {},
                
                'abr_mailing_street_number': {},
                'abr_mailing_street_name': {},
                'abr_mailing_unit': {},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_zip': {},
                'abr_mailing_country': {},
                
                'abr_assistant_check1': {},
                'abr_assistant_check2': {},
                'abr_assistant_phone': {},
                'abr_assistant_unit': {},
                'abr_assistant_zip': {},
                'abr_assistant_state_abbrev': {},
                'abr_assistant_city': {},
                'abr_assistant_street_number': {},
                'abr_assistant_street_name': {},
                'abr_assistant_first_name': {},
                'abr_assistant_middle_initial': {},
                'abr_assistant_last_name': {},
                'abr_assistant_suffix': {},
              }

  EXTRA_FIELDS = ["has_mailing_address", "UOCAVA", "moved_permanently", "A", "B", "C", "D", "last_residency_date", "residency_mm","residency_dd", "residency_yyyy"]
  
  def form_field_items
    [
     
      # {"need_assistance": {type: :checkbox}},
      # {"Assistant_Name": {visible: "need_assistance", required: :if_visible}},
      # {"Assistant_Address": {visible: "need_assistance", required: :if_visible, classes: "three-quarter"}},
      # {"Assistant_Apt": {visible: "need_assistance", classes: "last quarter"}},
      # {"Assistant_City": {visible: "need_assistance", required: :if_visible}},
      # {"Assistant_State": {visible: "need_assistance", required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true, classes: "half"}},
      # {"Asistant_Zip": {visible: "need_assistance", required: :if_visible, classes: "half last"}},
      # {"Assistant_Phone": {visible: "need_assistance", classes: "three-quarter"}}, #optional therefore no RegEx format enforcement?
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

  end

  

end
