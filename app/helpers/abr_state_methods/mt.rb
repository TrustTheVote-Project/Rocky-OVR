module AbrStateMethods::MT
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name Optional": {
      method: "middle name"
    },
    "Birthdate MMDDYYYY": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone Number Optional": {
      method: "phone"
    },
    "Email Address Optional": {
      method: "email"
    },
    "County where you reside and are registered to vote": {},
    "Montana Residence Address": {
      method: "address"
    },
    "City": {
      method: "city"
    },
    "Zip Code": {
      method: "zip"
    },
    "Mailing Address required if differs from residence address": {},
    "City and State": {},
    "Zip Code_2": {},
    "Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only": { 
      options: ["Off", "On"] },
    "Seasonal Mailing Address Optional": {},
    "City and State_2": {},
    "Zip Code_3": {},
    "Period mmddyyyymmddyyyy": {},
    "Yes I request an absentee ballot to be mailed to me for ALL elections in which I am eligible to vote as long as I reside at the address": { 
      options: ["Off", "On"],
      value: "Off" 
    },
    "I hereby request an absentee ballot for the upcoming election check only one": { 
      options: ["Off", "On"],
      value: "On"
    },
    "Primary": { 
      options: ["Off", "On"],
      value: "Off"
    },
    "General": { 
      options: ["Off", "On"],
      value: "On"
    },
    "Municipal": { 
      options: ["Off", "On"],
      value: "Off"
    },
    "Other": { 
      options: ["Off", "On"],
      value: "Off"
    },
    #"Signature of Elector": { options: [] }
    #"Date Signed": {}
    "Please send current Voter Information Pamphlet if applicable to this election": { options: ["Off", "On"] },
    "Receipt of absentee ballot by designee I received the absentee ballot for the applicant on": {},
    #"Date ballot received": {}
    #"Signature of Designee": { options: [] }
    #"Signature of Elector_2": { options: [] }
    #"Date Signed_2": {}
    "Please check this box to affirm that you do NOT want to receive an absentee ballot and instead want to vote at your local polling": { 
      options: ["Off", "On"],
      value: "Off"
    },
  }
  EXTRA_FIELDS = ["has_mailing_address", "designee"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"County where you reside and are registered to vote": {type: :select, required: true, include_blank: true, options: [
        "Beaverhead",
        "Big Horn",
        "Blaine",
        "Broadwater",
        "Carbon",
        "Carter",
        "Cascade",
        "Chouteau",
        "Custer",
        "Daniels",
        "Dawson",
        "Deer Lodge",
        "Fallon",
        "Fergus",
        "Flathead",
        "Gallatin",
        "Garfield",
        "Glacier",
        "Golden Valley",
        "Granite",
        "Hill",
        "Jefferson",
        "Judith Basin",
        "Lake",
        "Lewis And Clark",
        "Liberty",
        "Lincoln",
        "Madison",
        "McCone",
        "Meagher",
        "Mineral",
        "Missoula",
        "Musselshell",
        "Park",
        "Petroleum",
        "Phillips",
        "Pondera",
        "Powder River",
        "Powell",
        "Prairie",
        "Ravalli",
        "Richland",
        "Roosevelt",
        "Rosebud",
        "Sanders",
        "Sheridan",
        "Silver Bow",
        "Stillwater",
        "Sweet Grass",
        "Teton",
        "Toole",
        "Treasure",
        "Valley",
        "Wheatland",
        "Wibaux",
        "Yellowstone",
        "Yellowstone National Park",
      ]}},
      {"address_instructions": {type: :instructions}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address required if differs from residence address": {visible: "has_mailing_address"}},
      {"City and State": {visible: "has_mailing_address"}},
      {"Zip Code_2": {visible: "has_mailing_address"}},
      {"Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only": {type: :checkbox}},
      #TODO- lines 155-158 aren't actually disappearing when the above is unchecked....?
      {"Seasonal Mailing Address Optional": {visibe: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only")}},
      {"City and State_2": {visibe: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only")}},
      {"Zip Code_3": {visibe: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only")}},
      {"Period mmddyyyymmddyyyy": {visibe: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only")}},
      {"designee": {type: :checkbox}},
      {"Receipt of absentee ballot by designee I received the absentee ballot for the applicant on": {visible: "designee"}},
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