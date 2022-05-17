module AbrStateMethods::MT
  
  PDF_FIELDS = {
    "abr_last_name": {
      method: "last_name"
    },
    "abr_first_name": {
      method: "first_name"
    },
    "abr_middle_name": {
      method: "middle_name"
    },
    "abr_date_of_birth_mmddyyy": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "phone": {
      method: "phone"
    },
    "email": {
      method: "email"
    },
    "abr_county": {},
                "abr_street_number": {},
                "abr_street_name": {},
                "abr_city": {
                              method: "city"
                            },
                "abr_zip": {
                             method: "zip"
                           },

                "abr_mailing_street_number": {},
                "abr_mailing_street_name": {},
                "abr_mailing_city": {
                              method: "city"
                            },
                "abr_mailing_state_abbrev" {},
                "abr_mailing_zip": {
                             method: "zip"
                           },


    "Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only": { 
      options: ["Off", "On"] },
                "abr_mailing_street_number1": {},
                "abr_mailing_street_name1": {},
                "abr_mailing_city1": {
                                      method: "city"
                                    },
                "abr_mailing_state_abbrev1" {},
                "abr_mailing_zip1": {
                                     method: "zip"
                                   },

    "Period mmddyyyymmddyyyy": {
      method: "period_from_to"
    },
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
  EXTRA_FIELDS = ["has_mailing_address", "designee",  "period_from_mm", "period_from_dd", "period_from_yyyy", "period_to_mm", "period_to_dd", "period_to_yyyy"]
  
  
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
      {"Mailing Address required if differs from residence address": {visible: "has_mailing_address", required: :if_visible}},
      {"City and State": {visible: "has_mailing_address", required: :if_visible}},
      {"Zip Code_2": {visible: "has_mailing_address", required: :if_visible}},
      {"Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only": {type: :checkbox}},
      {"Seasonal Mailing Address Optional": {visible: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only"), required: :if_visible}},
      {"City and State_2": {visible: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only"), required: :if_visible}},
      {"Zip Code_3": {visible: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only"), required: :if_visible}},
      {"period_from": {
        visible: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only"), 
        type: :date, m: "period_from_mm", d: "period_from_dd", y: "period_from_yyyy"}},
      {"period_to": {
          visible: self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only"), 
          type: :date, m: "period_to_mm", d: "period_to_dd", y: "period_to_yyyy"}},
      {"designee_instructions": {type: :instructions}},
      {"designee": {type: :checkbox}},
      {"Receipt of absentee ballot by designee I received the absentee ballot for the applicant on": {visible: "designee"}},
    ]
  end
  
  def period_from
    fdates = [period_from_mm, period_from_dd, period_from_yyyy].collect {|d| d.blank? ? nil : d}.compact
    fdate  = fdates && fdates.length == 3 ? fdates.join("/") : nil
  end
  def period_to
    tdates = [period_to_mm, period_to_dd, period_to_yyyy].collect {|d| d.blank? ? nil : d}.compact
    tdate  = tdates && tdates.length == 3 ? tdates.join("/") : nil
  end
  
  def period_from_to
    [period_from, period_to].compact.join("-")
  end
  
  
  def custom_form_field_validations
    if self.has_mailing_address == "1"
      ["Mailing Address required if differs from residence address",
      "City and State",
      "Zip Code_2"].each do |f|
        custom_validates_presence_of(f)
      end
    end
    if self.send(self.class.make_method_name("Check if the mailing address listed above is for part of the year only and if so complete the information below for absentee ballot list only")) == "1"
      [
        "Seasonal Mailing Address Optional",
        "City and State_2",
        "Zip Code_3",
        "period_from", "period_to"
      ].each do |f|
        custom_validates_presence_of(f)
      end
    end
    if self.designee == "1"
      custom_validates_presence_of(self.class.make_method_name("Receipt of absentee ballot by designee I received the absentee ballot for the applicant on"))
    end
  end
  
 
end
