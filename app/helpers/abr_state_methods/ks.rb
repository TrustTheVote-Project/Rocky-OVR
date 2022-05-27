module AbrStateMethods::KS
  
  PDF_FIELDS = {
    "state_2": {},
    "county_1": {},
    "county_2": {},
    "identification_number": {sensitive: true},
    "First_Name": {
      method: "first_name"
    },
    "MI": {
      method: "middle_initial"
    },
    "Birthdate": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Last_Name": {
      method: "last_name"
    },
    "party": {
      options: ["Democratic", "Republican", "Off"], 
      value: "Off"
    },
    "Residential_Address": {
      method: "address"
    },
    "Mailing_Address": {},
    "City": {
      method: "city"
    },
    "Mailing_City": {},
    "State": {
      method: "home_state_abbrev"
    },
    "Mailing_State": {},
    "Zip_Code": {
      method: "zip"
    },
    "Mailing_Zip_Code": {},
    "Election_Date": {
      value: "11/03/2020"
    },
    "Phone_Number": {
      method: "phone"
    },
  }
  EXTRA_FIELDS = ["identification", "has_mailing_address","dln_soft_validation"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  def form_field_items
    [
      {"county_1": {type: :select, required: true, include_blank: true, options: [
        "Allen",
        "Anderson",
        "Atchison",
        "Barber",
        "Barton",
        "Bourbon",
        "Brown",
        "Butler",
        "Chase",
        "Chautauqua",
        "Cherokee",
        "Cheyenne",
        "Clark",
        "Clay",
        "Cloud",
        "Coffey",
        "Comanche",
        "Cowley",
        "Crawford",
        "Decatur",
        "Dickinson",
        "Doniphan",
        "Douglas",
        "Edwards",
        "Elk",
        "Ellis",
        "Ellsworth",
        "Finney",
        "Ford",
        "Franklin",
        "Geary",
        "Gove",
        "Graham",
        "Grant",
        "Gray",
        "Greeley",
        "Greenwood",
        "Hamilton",
        "Harper",
        "Harvey",
        "Haskell",
        "Hodgeman",
        "Jackson",
        "Jefferson",
        "Jewell",
        "Johnson",
        "Kearny",
        "Kingman",
        "Kiowa",
        "Labette",
        "Lane",
        "Leavenworth",
        "Lincoln",
        "Linn",
        "Logan",
        "Lyon",
        "Marion",
        "Marshall",
        "McPherson",
        "Meade",
        "Miami",
        "Mitchell",
        "Montgomery",
        "Morris",
        "Morton",
        "Nemaha",
        "Neosho",
        "Ness",
        "Norton",
        "Osage",
        "Osborne",
        "Ottawa",
        "Pawnee",
        "Phillips",
        "Pottawatomie",
        "Pratt",
        "Rawlins",
        "Reno",
        "Republic",
        "Rice",
        "Riley",
        "Rooks",
        "Rush",
        "Russell",
        "Saline",
        "Scott",
        "Sedgwick",
        "Seward",
        "Shawnee",
        "Sheridan",
        "Sherman",
        "Smith",
        "Stafford",
        "Stanton",
        "Stevens",
        "Sumner",
        "Thomas",
        "Trego",
        "Wabaunsee",
        "Wallace",
        "Washington",
        "Wichita",
        "Wilson",
        "Woodson",
        "Wyandotte",
      ]}},
      {"state_2": {type: :select, options: GeoState.collection_for_select, required: true}},
      {"county_2": {required: true}},
      {"identification": {type: :radio, options: ["dln_yes", "dln_no"]}},
      {"identification_number": {visible: "identification_dln_yes", required: "show_star", min: 9, max: 9, ui_regexp:"^[kK][0-9]{8}$"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address": {visible: "has_mailing_address"}},
      {"Mailing_City": {visible: "has_mailing_address"}},
      {"Mailing_State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select}},
      {"Mailing_Zip_Code": {visible: "has_mailing_address"}},
      {"dln_soft_validation": {type: :hidden}}
    ]
  end
  
  def custom_form_field_validations
    if self.identification.to_s == "dln_yes"
      custom_validates_presence_of("identification_number")
    end
    if self.has_mailing_address == "1"
      [
        "Mailing_City",
        "Mailing_Address",
        "Mailing_State",
        "Mailing_Zip_Code"        
      ].each do |f|
        custom_validates_presence_of(f)
      end
    end
  end
  
 
end