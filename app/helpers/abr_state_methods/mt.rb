module AbrStateMethods::MT
  
  PDF_FIELDS = {'Period mmddyyyymmddyyyy': {},
                'Signature of Elector': {},
                'Date Signed': {},
                'Date ballot received': {},
                'Signature of Designee': {},
                'Signature of Elector_2': {},
                'Date Signed_2': {},
                'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {},
                'phone': {},
                'abr_county': {:method=>"county"},
                'abr_city': {:method=>"city"},
                'abr_mailing_zip': {:method=>"zip"},
                'abr_mailing_street_number': {},
                'abr_mailing_city': {:method=>"city"},
                'abr_mailing_state_abbrev': {:method=>"home_state_abbrev"},
                'abr_zip': {:method=>"zip"},
                'abr_mailing_street_name': {},
                'abr_mailing_unit': {:method=>"unit"},
                'seasonal_zip': {},
                'seasonal_Mailing_Address': {},
                'seasonal_City_State': {},
                'abr_election_type_selections': {},
                'abr_election_type_selections2': {},
                'abr_election_type6_name': {},
                'abr_election_date': {},
                'abr_request_name': {},
                'send_pamphlet': {},
                'dont_want_ab': {},
                'abr.email': {},
                'date_of_birth_mm_dd_yyyy': {},
                'abr_street_number': {},
                'abr_street_name': {},
                'abr_unit': {:method=>"unit"},
                'is_mailing_addr_seasonal': {}
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
