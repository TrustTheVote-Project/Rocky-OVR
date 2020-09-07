module AbrStateMethods::MA
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
    "Legal Voting Residence": {
      method: "address"
    },
    "1": {
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
    "Mail Ballot to 1": {},
    "Mail Ballot to 2": {},
    "All elections this year": { 
      options: ["Off", "On"],
      value: "Off"
    },
    "All general elections No primaries": { 
      options: ["Off", "On"], 
      value: "On"
    },
    "A specific election": { 
      options: ["Off", "On"], 
      value: "Off"
    },
    "This application is being made by a family member of the voter": { options: ["Off", "On"] },
    "Voter is a member of military on active duty or dependent family member of": { options: ["Off", "On"] },
    "Voter is a Massachusetts citizen residing overseas": { options: ["Off", "On"] },
    "Voter has been admitted to a healthcare facility after noon on the fifth day": { options: ["Off", "On"] },
    "Voter required assistance in completing application due to physical disability": { options: ["Off", "On"] },
    "Relationship to voter": {},
    "the ballot": {},
    "Assisting persons name": {},
    "Assisting persons address": {},
    #"Date": {}
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]

  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Mail Ballot to 1": {visible: "has_mailing_address", required: :if_visible}},
      {"Mail Ballot to 2": {visible: "has_mailing_address", required: :if_visible}},
      {"This application is being made by a family member of the voter": {type: :checkbox}},
      {"Relationship to voter": {visible: self.class.make_method_name("This application is being made by a family member of the voter"), required: :if_visible}},
      {"Voter is a member of military on active duty or dependent family member of": {type: :checkbox}},
      {"Voter is a Massachusetts citizen residing overseas": {type: :checkbox}},
      {"Voter has been admitted to a healthcare facility after noon on the fifth day": {type: :checkbox}},
      {"the ballot": {visible: self.class.make_method_name("Voter has been admitted to a healthcare facility after noon on the fifth day"), required: :if_visible}},
      {"Voter required assistance in completing application due to physical disability": {type: :checkbox}},
      {"Assisting persons name": {visible: self.class.make_method_name("Voter required assistance in completing application due to physical disability"), required: :if_visible}},
      {"Assisting persons address": {visible: self.class.make_method_name("Voter required assistance in completing application due to physical disability"), required: :if_visible}},
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