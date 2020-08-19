module AbrStateMethods::NV
  
  PDF_FIELDS = {
    "LastName": {
      method: "last_name"
    },
    "FirstName": {
      method: "first_name"
    },
    "MiddleName": {
      method: "middle_name"
    },
    "PhysicalAddress": {
      method: "address_line_1"
    },
    "PhysicalCity": {
      method: "city"
    },
    "PhysicalZip": {
      method: "zip"
    },
    "DateOfBirth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "RegistrationNo": {sensitive: true},
    "MailingAddress": {},
    "MailingCity": {},
    "MailingZip": {},
    "Primary": { 
      options: ["Off", "Primary"],
      value: "Off"
    },
    "General": { 
      options: ["Off", "General"],
      value: "General"
    },
    "MilitaryDomestic": { options: ["Off", "MilitaryDomestic"] },
    "MilitaryOverseas": { options: ["Off", "MilitaryOverseas"] },
    "CivilianOverseas": { options: ["Off", "CivilianOverseas"] },
    #"RequestDate": {}
    "ProvidedBy": {
      value: "Rock the Vote"
    },
    "Phone": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "YES Permanent Ballot": { options: ["Off", "Yes"], value: "Off" },
    "MailingState": {},
    "ResApt": {
      method: "unit"
    },
    "MailApt": {},
    "Special": { options: ["Off", "Special"], value: "Off" },
    "ALL": { options: ["Off", "Special"], value: "Off" },
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  
  def form_field_items
    [
      {"RegistrationNo": {}},
      {"military_instructions": {type: :instructions}},
      {"MilitaryDomestic": {type: :checkbox}},
      {"MilitaryOverseas": {type: :checkbox}},
      {"CivilianOverseas": {type: :checkbox}},
      {"has_mailing_address": {type: :checkbox}},
      {"MailingAddress": {visible: "has_mailing_address", required: :if_visible}},
      {"MailApt": {visible: "has_mailing_address"}},
      {"MailingCity": {visible: "has_mailing_address", required: :if_visible}},
      {"MailingState": {visible: "has_mailing_address", required: :if_visible,  type: :select, options: GeoState.collection_for_select, include_blank: true, }},
      {"MailingZip": {visible: "has_mailing_address", required: :if_visible, min: 5, max: 10}},
    ]
  end
  
  def custom_form_field_validations
  end
  
 
end