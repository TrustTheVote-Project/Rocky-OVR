module AbrStateMethods::NY
  
  PDF_FIELDS = {
    "date of birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "suffix": {
      method: "name_suffix"
    },
    "middle initial": {
      method: "middle_initial"
    },
    "first name": {
      method: "first_name"
    },
    "last name or surname": {
      method: "last_name"
    },
    "phone number (optional)": {
      method: "phone"
    },
    "email (optional)": {
      method: "email"
    },
    "county where you live": { method: "registration_county_name" },
    "street (Residence)": {
      method: "address_line_1"
    },
    "city (Residence)": {
      method: "city"
    },
    "zip code (Residence)": {
      method: "zip"
    },
    "Date (Applicant Signed)": { method: "date_for_signature" },
    # "(address of witness to mark)": {},
    # "Name of Voter:": {
    #   method: "full_name"
    # },
    #(signature of witness to mark)
    #Date (Applicant Marked)
    #Mark: (Applicant mark in lieu of signature)
    "mailing_address_street_number_general":{ 
      method:"override_street_number"
    },
    "street_name_general":{ 
      method:"override_street_name"
    },
    "apartment_general":{ 
      method:"override_unit"
    },
    "city_general":{ 
      method:"override_city"
    },
    "state_general":{ 
      method:"override_home_state_abbrev"
    },
    "zip_general":{ 
      method:"override_zip"
    },
    "authorized_recipient_name_general": {},
    "apartment (Residence)": {
      method: "unit"
    },
    "reason": {
      options: ["absence", "caregiver", "patient", "permanent_illness", "prisoner", "temporary_illness"]
    },
    "general_only": { options: ["Off", "Yes"], value: "Off" },
    "special_only": { options: ["Off", "Yes"], value: "Yes" },
    "primary_only": { options: ["Off", "Yes"], value: "Off" },
    "any_election": { options: ["Off", "Yes"], value: "Off" },
    "delivery_general": {
      options: ["authorized_recipient", "in_person", "mail"]
    },
    #"voter_signature"
  }
  EXTRA_FIELDS = ["has_mailing_address", "witness", "mail_street_number", "mail_street_name", "mail_unit", "mail_city", "mail_state", "mail_zip"]
  
  
  def form_field_items
    [
      {"reason": {type: :radio, required: true}},
      {"delivery_general": {type: :radio, required: true}},
      {"authorized_recipient_name_general": {visible: "delivery_general_authorized_recipient", required: "star"}}, # :is_visible throws err
      {"has_mailing_address": {type: :checkbox, visible: "delivery_general_mail"}},
      {"mail_street_number": {visible: "has_mailing_address",required: "star", classes: "quarter"}},
      {"mail_street_name": {visible: "has_mailing_address",required:"star", classes: "half"}},
      {"mail_unit": {visible: "has_mailing_address", classes: "quarter last"}},
      {"mail_city": {visible: "has_mailing_address", required: "star", classes: "half"}},
      {"mail_state": {visible: "has_mailing_address", required: "star", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"mail_zip": {visible: "has_mailing_address",required:"star", classes: "quarter last"}},
    ]
  end
  
  def override_field_value(override, fieldname1, fieldname2) 
    if (override) 
      #return self.send("#{self.class.make_method_name(fieldname2)}") 
      return self.send(fieldname2) 
    else 
      #return self.send("#{self.class.make_method_name(fieldname1)}")
      return self.send(fieldname1)
    end
  end

  def override_mailing_address_field (fieldname1, fieldname2)
      return override_field_value((self.has_mailing_address.to_s == "1"), fieldname1, fieldname2)
  end

  def conditional_set_and_override_mailing_address_field (fieldname1, fieldname2) 
    if self.delivery_general == "mail"
      return override_mailing_address_field(fieldname1, fieldname2)
    end
  end

  def override_street_number
    return conditional_set_and_override_mailing_address_field("street_number", "mail_street_number")
  end 
  
  def override_street_name
    return conditional_set_and_override_mailing_address_field("street_name", "mail_street_name")
  end

  def override_unit
    return conditional_set_and_override_mailing_address_field("unit", "mail_unit")
  end

  def override_city
    return conditional_set_and_override_mailing_address_field("city", "mail_city")
  end

  def override_home_state_abbrev
    return conditional_set_and_override_mailing_address_field("home_state_abbrev", "mail_state")
  end 

  def override_zip
    return conditional_set_and_override_mailing_address_field("zip", "mail_zip")
  end
  
  REQUIRED_MAILING_ADDRESS_FIELDS = [
    "mail_street_number",
    "mail_street_name",
    #"apartment (General (or Special) Election Ballot Mailing Address)",
    "mail_city",
    "mail_state",
    "mail_zip"
  ]

  def require_mailing_fields
    REQUIRED_MAILING_ADDRESS_FIELDS.each do |field|
      custom_validates_presence_of(field)
    end
  end

  def custom_form_field_validations  
    #if mailing address different, require it
    if self.has_mailing_address.to_s == "1"
      require_mailing_fields
    end

    #if deliver by proxy, require proxy
    if self.delivery_general == "authorized_recipient"
      custom_validates_presence_of("authorized_recipient_name_general")
    end
    
  end


 
end