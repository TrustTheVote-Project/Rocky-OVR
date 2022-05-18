module AbrStateMethods::NM
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},
    "abr_id_selections": {
      options: [
        "abr_id_type1",
        "abr_id_no1",
      ]
    },
    "abr_full_name": {method: "full_name"},
    "abr_address_line_1": {method: "address_line_1"},
    "abr_address_line_2": {method: "address_line_2"},
    "abr_address_city_state_zip": {method: "address_city_state_zip"},
    "abr_county": {},
    "abr_mailing_address_line_1": {},
    "abr_mailing_unit": {},
    "abr_mailing_city": {},
    "abr_mailing_state_abbrev": {},
    "abr_mailing_zip": {},
    "abr_date_of_birth_YYYY": {method: "date_of_birth_yyyy"},
    "abr_phone": {method: "phone"},
  }
  EXTRA_FIELDS = ["abr_check_mailing_address"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Bernalillo",
        "Catron",
        "Chaves",
        "Cibola",
        "Colfax",
        "Curry",
        "De Baca",
        "Dona Ana",
        "Eddy",
        "Grant",
        "Guadalupe",
        "Harding",
        "Hidalgo",
        "Lea",
        "Lincoln",
        "Los Alamos",
        "Luna",
        "McKinley",
        "Mora",
        "Otero",
        "Quay",
        "Rio Arriba",
        "Roosevelt",
        "Sandoval",
        "San Juan",
        "San Miguel",
        "Santa Fe",
        "Sierra",
        "Socorro",
        "Taos",
        "Torrance",
        "Union",
        "Valencia",
      ]}},
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_line_1": {visible: "abr_check_mailing_address", required: :if_visible, classes: "three-quarter"}},
      {"abr_mailing_unit": {visible: "abr_check_mailing_address", classes: "quarter"}},
      {"abr_mailing_city": {visible: "abr_check_mailing_address", required: :if_visible, classes: "half"}},
      {"abr_mailing_state_abbrev": {visible: "abr_check_mailing_address", required: :if_visible, classes: "quarter", options: GeoState.collection_for_select}},
      {"abr_mailing_zip": {visible: "abr_check_mailing_address", required: :if_visible, classes: "quarter"}},      
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
  
  
  def custom_form_field_validations
    # e.g:
    # make sure delivery is selected if reason ==3
    # e.g:
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end