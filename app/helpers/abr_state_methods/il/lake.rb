module AbrStateMethods::IL::Lake
  
  PDF_FIELDS = {
    "TownshipPrecinct": {},
    "Name": {
      method: "full_name"
    },
    "Address": {
      method: "address"
    },
    "CityZip": {}, #TODO - make it work
    "DoB": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Email": {
      method: "email"
    },
    "Daytime Telephone": {
      method: "phone"
    },
    "EspMat": { options: ["Off", "Yes"] },
    "1": {
      method: "mailing_name"
    },
    "2": {},
    "3": {},
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def "mailing_name"
    #TODO- autofill with "full_name" if "has_mailing_address" is checked, otherwise leave blank
  end
  
  
  def form_field_items
    [
      {"TownshipPrecinct": {}},
      {"has_mailing_address": {type: :checkbox}},
      {"2": {visible: "has_mailing_address"}},
      {"3": {visible: "has_mailing_address"}},
      {"EspMat": {type: :checkbox}},
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
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end