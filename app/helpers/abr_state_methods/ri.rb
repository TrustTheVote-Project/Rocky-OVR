module AbrStateMethods::RI
  
  PDF_FIELDS = {
    "Text Field 4": {
      method: "full_name"
    },
    "Text Field 11": {},
    "Text Field 5": {
      method: "address"
    },
    "Text Field 12": {},
    "Text Field 6": {
      method: "city"
    },
    "Text Field 7": {
      method: "zip"
    },
    "Text Field 8": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Text Field 9": {
      method: "phone"
    },
    "Text Field 14": {},
    "Text Field 15": {},
    "Text Field 16": {},
    "Text Field 10": {
      method: "email"
    },
    "Text Field 18": {}, #TODO - if "eligibility_military" is selected, autofill with email
    "eligibility": { options: ["absent", "confined", "incapacitated", "military"] },
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
      {"Text Field 11": {visible: "has_mailing_address"}},
      {"Text Field 12": {visible: "has_mailing_address"}},
      {"Text Field 14": {visible: "has_mailing_address", classes: "half"}},
      {"Text Field 15": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Text Field 16": {visible: "has_mailing_address", classes: "quarter last"}},
      {"eligibility": {type: :radio, required: true}}
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