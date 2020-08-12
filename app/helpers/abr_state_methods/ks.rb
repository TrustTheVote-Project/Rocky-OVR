module AbrStateMethods::KS
  
  PDF_FIELDS = {
    "state_2": {},
    "county_1": {},
    "county_2": {},
    "identification_number": {},
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
  EXTRA_FIELDS = ["identification", "has_mailing_address"]
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
      {"state_2": {}},
      {"county_2": {}},
      {"identification": {type: :radio, options: ["dln_yes", "dln_no"]}},
      {"identification_number": {visible: "identification_dln_yes"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing_Address": {visible: "has_mailing_address"}},
      {"Mailing_City": {visible: "has_mailing_address"}},
      {"Mailing_State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing_Zip_Code": {visible: "has_mailing_address"}},
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