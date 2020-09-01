module AbrStateMethods::IL::Chicago
  
  PDF_FIELDS = {
    "Voter Registration Number (if known)": {},
    "Precinct": {},
    "Ward": {},
    "Applicants Name": {
      method: "full_name"
    },
    "Year of Birth": {
      method: "date_of_birth_yyyy"
    },
    "Street Address": {
      method: "address_line_1"
    },
    "Apartment Number": {
      method: "unit"
    },
    "Zip Code": {
      method: "zip"
    },
    "Email": {
      method: "email"
    },
    "Area code": {}, #TODO- phone number area code
    "Phone1": {}, #TODO - phone middle 3 digits
    "Phone2": {}, #TODO - phone last 4 digits
    "Mailed Ballot Sent": { options: ["0", "1", "Yes"] },
    "Address": {},
    "Apartment Number2": {},
    "City": {},
    "State": {},
    "ZiP Code": {},
    #"Day": {},
    #"Month": {},
    #"Year": {},
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Address": {visible: "has_mailing_address", classes: "three-quarter"}},
      {"Apartment Number2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"City": {visible: "has_mailing_address", classes: "half"}},
      {"State": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZiP Code": {visible: "has_mailing_address", classes: "quarter last"}},
      {"Mailed Ballot Sent": {type: :radio, required: true}},
      {"Voter Registration Number (if known)": {classes: "half"}},
      {"Precinct": {classes: "quarter"}},
      {"Ward": {classes: "quarter last"}},
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