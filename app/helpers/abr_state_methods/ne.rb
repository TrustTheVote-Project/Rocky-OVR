module AbrStateMethods::NE
  
  PDF_FIELDS = {
    #"Date1": {}
    "County1": {},
    "County Election Office Address1": {},
    "City1": {},
    "Zip Code1": {},
    #TODO lines 5-8 are county clerk's address
    "Registered Address1": {
      method: "full_address_1_line"
    },
    "County Name2": {},
    "Month1": {
      value: "November"
    },
    "Day1": {
      value: "03"
    },
    "Last Two Digits of Year1": {
      value: "20"
    },
    "Address Line 1": {
      method: "full_name"
    },
    "Address Line 2": {},
    "City, State, Zip1": {},
    "Phone1": {
      method: "phone"
    },
    "Email1": {
      method: "email"
    },
    "Voters Printed Name": {
      method: "full_name"
    },
    "DOB Month2": {
      method: "date_of_birth_mm"
    },
    "DOB Day2": {
      method: "date_of_birth_dd"
    },
    "DOB Year2": {
      method: "date_of_birth_yyyy"
    },
    "Relationship": {},
    "Election Type": { 
      options: ["General", "Special"],
      value: "General"
    },
    "Ballot Method": { options: ["mail_ballot", "take_ballot", "vote_here"] },
  }
  EXTRA_FIELDS = ["has_mailing_address", "agent"]
  
  #def mailing_address_is_registered_address
  #   TODO when "has_mailing_address" is NOT checked, this should be filled in with the registered address.
  #end
  
  
  def form_field_items
    [
      {"County Name2": {type: :select, required: true, include_blank: true, options: [
        "Adams",
        "Antelope",
        "Arthur",
        "Banner",
        "Blaine",
        "Boone",
        "Box Butte",
        "Boyd",
        "Brown",
        "Buffalo",
        "Burt",
        "Butler",
        "Cass",
        "Cedar",
        "Chase",
        "Cherry",
        "Cheyenne",
        "Clay",
        "Colfax",
        "Cuming",
        "Custer",
        "Dakota",
        "Dawes",
        "Dawson",
        "Deuel",
        "Dixon",
        "Dodge",
        "Douglas",
        "Dundy",
        "Fillmore",
        "Franklin",
        "Frontier",
        "Furnas",
        "Gage",
        "Garden",
        "Garfield",
        "Gosper",
        "Grant",
        "Greeley",
        "Hall",
        "Hamilton",
        "Harlan",
        "Hayes",
        "Hitchcock",
        "Holt",
        "Hooker",
        "Howard",
        "Jefferson",
        "Johnson",
        "Kearney",
        "Keith",
        "Keya Paha",
        "Kimball",
        "Knox",
        "Lancaster",
        "Lincoln",
        "Logan",
        "Loup",
        "McPherson",
        "Madison",
        "Merrick",
        "Morrill",
        "Nance",
        "Nemaha",
        "Nuckolls",
        "Otoe",
        "Pawnee",
        "Perkins",
        "Phelps",
        "Pierce",
        "Platte",
        "Polk",
        "Red Willow",
        "Richardson",
        "Rock",
        "Saline",
        "Sarpy",
        "Saunders",
        "Scotts Bluff",
        "Seward",
        "Sheridan",
        "Sherman",
        "Sioux",
        "Stanton",
        "Thayer",
        "Thomas",
        "Thurston",
        "Valley",
        "Washington",
        "Wayne",
        "Webster",
        "Wheeler",
        "York",
      ]}},
      {"Ballot Method": {type: :radio}},
      {"has_mailing_address": {type: :checkbox}}, #TODO- when not checked, autofill the mailing with residential
      {"Address Line 2": {visible: "has_mailing_address"}},
      {"City, State, Zip1": {visible: "has_mailing_address"}},
      {"agent": {type: :checkbox}},
      {"Relationship": {visible: "agent"}},
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