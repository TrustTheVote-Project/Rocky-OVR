module AbrStateMethods::NM
  
  PDF_FIELDS = {
    "county": {},
    "Election": { 
      options: ["General", "Local", "Municipal", "Off", "Primary"],
      value: "General"
    },
    "street_address": {
      method: "address"
    },
    "city_state_zip": {
      method: "address_city_state_zip"
    },
    "birth_year": {
      method: "date_of_birth_yyyy"
    },
    "voter_name": {
      method: "full_name"
    },
    "mail_address1": {},
    "mail_address2": {},
    "mail_address3": {},
    #"date": {},
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"county": {type: :select, required: true, include_blank: true, options: [
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
      {"has_mailing_address": {type: :checkbox}},
      {"mail_address1": {visible: "has_mailing_address"}},
      {"mail_address2": {visible: "has_mailing_address"}},
      {"mail_address3": {visible: "has_mailing_address"}},
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