module AbrStateMethods::VA
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Suffix": {
      method: "name_suffix"
    },
    "in the citycounty of": {
      method: "city"
    },
    "Birth_Year": {},
    "SSN_Last_4": {},
    "Election": {
      options: ["Democratic_Primary", "General", "Republican_Primary", "Off"],
      value: "General"
    },
    "VBM_for_all": {
      options: ["No", "Off", "Yes"],
      value: "No"
    },
    "Primary_Ballot": {
      options: ["Democratic_Party", "None", "Off", "Republican_Party"],
      value: "None"
    },
    "Address_1": {
      method: "address"
    },
    "Mailing_Address_1": {},
    "Address_2": {
      method: "unit"
    },
    "Mailing_Address_2": {},
    "Zip_Code": {
      method: "zip"
    },
    "Address_3": {
      method: "city"
    },
    "Mailing_Address_3": {},
    "Mailing_Zip_Code": {},
    "Mailing_State": {},
    "Mailing_Country": {},
    "Telephone": {
      method: "phone"
    },
    "Email_Fax": {
      method: "email"
    },
    "Last_Date_of_Residency": {},
    "Category_Code": {}, #TODO - this is a text field, but really should be a series of checkboxes...
    "Deliver_to": {
      options: ["Residence", "ballot_mailing_address", "email_address"]
    },
    "need_assistance": {
      options: ["Off", "On"]
    },
    "Assistant_Name": {},
    "Assistant_City": {},
    "Assistant_Address": {},
    "Assistant_State": {},
    "Assistant_Phone": {},
    "Assistant_Apt": {},
    "Asistant_Zip": {},
    #assistant_signature
    #voter_signature
    #Asistant_Sign_Date
    #Voter_Sign_Date
   
  }
  EXTRA_FIELDS = ["has_mailing_address", "UOCAVA", "moved_permanently", "A", "B", "C", "D"]
  
  def form_field_items
    [
      {"Birth_Year": {min: 4, max: 4}},
      {"SSN_Last_4": {min: 4, max: 4}},
      {"UOCAVA": {type: :checkbox}},
      #TODO- the text field "Category_Code" should be filled in with the letter(s) of whatever is checked below: A, B, C, and/or D
      {"A": {type: :checkbox, visible: "UOCAVA"}},
      {"B": {type: :checkbox, visible: "UOCAVA"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"C": {type: :checkbox, visible: "UOCAVA"}},
      {"moved_permanently": {visible: "C", type: :checkbox}}, #TODO- can you change the placement of this? It really should be indented so the user knows it's a subset of the C option.
      {"Last_Date_of_Residency": {visible: "moved_permanently"}}, #TODO- this should also be indented the same amount as above
      {"D": {type: :checkbox, visible: "UOCAVA"}}, #TODO- this text is too long and gets cut off. Can that be fixed?
      {"Deliver_to": {visible: "UOCAVA", type: :radio}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address_1": {visible: "has_mailing_address"}},
      {"Mailing_Address_2": {visible: "has_mailing_address"}},
      {"Mailing_Address_3": {visible: "has_mailing_address"}},
      {"Mailing_State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing_Zip_Code": {visible: "has_mailing_address", min: 5, max: 10}},
      {"Mailing_Country": {visible: "has_mailing_address"}},
      {"need_assistance": {type: :checkbox}},
      {"Assistant_Name": {visible: "need_assistance"}},
      {"Assistant_Address": {visible: "need_assistance"}},
      {"Assistant_Apt": {visible: "need_assistance"}},
      {"Assistant_City": {visible: "need_assistance"}},
      {"Assistant_State": {visible: "need_assistance", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Asistant_Zip": {visible: "need_assistance"}},
      {"Assistant_Phone": {visible: "need_assistance"}},
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