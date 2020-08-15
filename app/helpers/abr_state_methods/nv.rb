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
    "RegistrationNo": {},
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
      value: "Rock the Vote" #TODO yes? no?
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
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"RegistrationNo": {}},
      {"military_instructions": {type: :instructions}},
      {"MilitaryDomestic": {type: :checkbox}}, #TODO- indent lines 70-72 so they read as one question
      {"MilitaryOverseas": {type: :checkbox}},
      {"CivilianOverseas": {type: :checkbox}},
      {"has_mailing_address": {type: :checkbox}},
      {"MailingAddress": {visible: "has_mailing_address"}},
      {"MailApt": {visible: "has_mailing_address"}},
      {"MailingCity": {visible: "has_mailing_address"}},
      {"MailingState": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
      {"MailingZip": {visible: "has_mailing_address", min: 5, max: 10}},
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
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end