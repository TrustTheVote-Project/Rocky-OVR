module AbrStateMethods::IL::Will_county
  
  PDF_FIELDS = {
    "Applicants Name": {
      method: "full_name"
    },
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Permanent Address": {
      method: "full_address_1_line"
    },
    "Phone Number": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "Number and Street": {},
    "City": {},
    "State": {},
    "Zip Code": {},
    "Number and Street_2": {},
    "City_2": {},
    "State_2": {},
    "Zip Code_2": {},
    #"Date": {}
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["change_of_address", "has_mailing_address"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Number and Street": {visible: "has_mailing_address"}},
      {"City": {visible: "has_mailing_address", classes: "half"}},
      {"State": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Zip Code": {visible: "has_mailing_address", classes: "quarter last"}},
      {"change_of_address": {type: :checkbox}},
      {"Number and Street_2": {visible: "change_of_address"}},
      {"City_2": {visible: "change_of_address", classes: "half"}},
      {"State_2": {visible: "change_of_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Zip Code_2": {visible: "change_of_address", classes: "quarter last"}},
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