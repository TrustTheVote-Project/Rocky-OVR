module AbrStateMethods::NJ
  
  PDF_FIELDS = {
    "2 Last Name Type or Print": {
      method: "last_name"
    },
    "First Name Type or Print": {
      method: "first_name"
    },
    "Middle Name or Initial": {
      method: "middle_name"
    },
    "Suffix Jr Sr III": {
      method: "name_suffix"
    },
    "Street Address or RD": {
      method: "address_line_1"
    },
    "Apt": {
      method: "unit"
    },
    "Municipality CityTown": {
      method: "city"
    },
    "State": {
      method: "home_state_abbrev"
    },
    "Zip": {
      method: "zip"
    },
    "7 EMail Address Optional": {
      method: "email"
    },
    "Apt_2": {},
    "Municipality CityTown_2": {},
    "Address of Messenger": {},
    "Apt_3": {},
    "Municipality CityTown_3": {},
    "State_3": {},
    "Election": { 
      options: ["All", "Fire", "General", "Municipal", "Off", "Primary", "School", "Special"],
      value: "General"
    },
    "UOCAVA": { options: ["UOCAVA_1", "UOCAVA_2", "UOCAVA_3", "UOCAVA_4"] },
    #"voter_signature": {}
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone": {
      method: "phone"
    },
    "Same_Address": { 
      options: ["Off", "Yes"], 
      method:"same_address_conditional" 
    }, #TODO- autofill "Yes" if "has_mailing_address" is NOT checked #TODONE
    "Mailing_Address_1": {
      method: "full_name_conditional" #Only if different mailing address
    },
    "Mailing_Address_2": {},
    "Mailing_Address_3": {},
    "Mailing_Address_4": {},
    #"Todays_Date": {}
    #"Signature_of_Assistor": {}
    #"Date_Assistor": {}
    "State_2": {},
    "Zip_2": {},
    "Address_Assistor": {},
    "Name_Assistor": {},
    "Authorizied_Messenger_Name": {},
    "Date_of_Birth_Messenger": {},
    #"voter_signature_2": {},
    #"messenger_signature": {}
    #"Signed_Date": {}
    #"messenger_date": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "messenger"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address_2":{visible: "has_mailing_address"}},
      {"Mailing_Address_3":{visible: "has_mailing_address"}},
      {"UOCAVA": {type: :radio}},
      {"assistant": {type: :checkbox}},
      {"Name_Assistor": {visible: "assistant"}},
      {"Address_Assistor": {visible: "assistant", classes: "three-quarter"}},
      {"Apt_2": {visible: "assistant", classes: "quarter last"}},
      {"Municipality CityTown_2": {visible: "assistant", classes: "half"}},
      {"State_2": {visible: "assistant", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Zip_2": {visible: "assistant", classes: "quarter last"}},
      {"messenger": {type: :checkbox}},
      {"Authorizied_Messenger_Name": {visible: "messenger"}},
      {"Address of Messenger": {visible: "messenger", classes: "three-quarter"}},
      {"Apt_3": {visible: "messenger", classes: "quarter last"}},
      {"Municipality CityTown_3": {visible: "messenger", classes: "half"}},
      {"State_3": {visible: "messenger", classes: "half last", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Date_of_Birth_Messenger": {visible: "messenger"}},
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
  
    # Methods below map from UI attributes to PDF fields

    def same_address_conditional
      return self.has_mailing_address.to_s == "1" ? "Off" : "Yes"
    end

    def full_name_conditional
      if(self.has_mailing_address.to_s == "1")
        return self.full_name
      end
    end

  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end