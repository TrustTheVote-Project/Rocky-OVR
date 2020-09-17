module AbrStateMethods::IL::Dekalb
  
  PDF_FIELDS = {
    "Applicants Name": {
      method: "full_name"
    },
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Street Address": {
      method: "address"
    },
    "Daytime Cell Phone": {
      method: "phone"
    },
    "City State Zip": {
      method: "address_city_state_zip"
    },
    "Email": {
      method: "email"
    },
    #"Date": {}
    "Signature": {
      method: "full_name"
    },
    "Text1": {
      method: "mailing_name"
    },
    "Text2": {},
    "Text3": {},
    "Text4": {},
    "Election": {
      value: "November 3, 2020 General Election"
    },
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "mail_address","mail_unit","mail_city","mail_state","mail_zip"]
  
  def mailing_name
    #TODO- autofill with "full_name" if "has_mailing_address" is checked, otherwise leave blank
    return full_name if self.has_mailing_address.to_s=='1'
  end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Text2": {visible: "has_mailing_address"}},
      {"Text3": {visible: "has_mailing_address", required: :if_visible}},
      {"Text4": {visible: "has_mailing_address", required: :if_visible}},      
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