module AbrStateMethods::MA
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
     "voter_address1":{
      method: "address"
    },

     "voter_address2": {
      method: "address_city_state_zip"
    },

    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Telephone Number": {
      method: "phone"
    },
    "Email Address": {
      method: "email"
    },
    "mailing_address": {
      method: "override_mailing_address",
    },

    "assistance_required": { options: ["Off", "On"] },

    #"Assisting persons name": {},
    "assisting_person": {},
    "Assisting persons address": {},
    "Date": { method: "date_for_signature" }
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "mailing_address_input"]

  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"mailing_address_input": {visible: "has_mailing_address", required: :if_visible}},
      {"assistance_required": {type: :checkbox}},
      {"assisting_person": {visible: "assistance_required", required: :if_visible}},
      {"Assisting persons address": {visible: "assistance_required", required: :if_visible}},
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
  

  def override_field_value(override, fieldname1, fieldname2) 
    if (override) 
        return self.send(fieldname2) 
    else 
      return self.send(fieldname1)
    end
  end

  def override_mailing_address_field (fieldname1, fieldname2)
      return override_field_value((self.has_mailing_address.to_s == "1"), fieldname1, fieldname2)
  end

  def override_mailing_address
    return override_mailing_address_field("full_address_1_line", "mailing_address_input")
  end

  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end