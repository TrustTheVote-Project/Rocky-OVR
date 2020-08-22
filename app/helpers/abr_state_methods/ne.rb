module AbrStateMethods::NE
  
  def registrar_address_lines
    unless @registrar_address_lines
      @registrar_address_lines = state_registrar_address.split(/<br\/?>/)
    end
  end
  
  def registrar_address_line_1
    registrar_address_lines[0]
  end
  
  def registrar_address_line_2
    registrar_address_lines[1]
  end
  
  def registrar_address_city
    registrar_address_lines[2]&.split(",")&.first
  end
  
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
      method: "mailing_address_name_line"
    },
    "Address Line 2": { method: "mailing_or_residence_address" },
    "City, State, Zip1": { method: "mailing_or_residence_city_state_zip" },
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
  EXTRA_FIELDS = ["has_mailing_address", "agent", "mailing_address", "mailing_city_state_zip"]
  
  def mailing_address_name_line
    return nil unless ballot_method == "mail_ballot"
    return full_name
  end
  
  def mailing_or_residence_address
    return nil unless ballot_method == "mail_ballot"
    if self.has_mailing_address == "1"
      return self.mailing_address
    else
      return address
    end
  end
  
  def mailing_or_residence_city_state_zip
    return nil unless ballot_method == "mail_ballot"
    if self.has_mailing_address == "1"
      return self.mailing_city_state_zip
    else
      return address_city_state_zip
    end
  end
  
  
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
      {"Ballot Method": {type: :radio, required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"mailing_address": {visible: "has_mailing_address", required: :if_visible}},
      {"mailing_city_state_zip": {visible: "has_mailing_address", required: :if_visible}},
      {"agent": {type: :checkbox}},
      {"Relationship": {visible: "agent", required: :if_visible}},
    ]
  end  
  
  def custom_form_field_validations
  end
  
 
end