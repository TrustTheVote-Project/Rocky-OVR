module AbrStateMethods::IA
  
  def dob_m1
    self.date_of_birth_mm_dd_yyyy[0]
  end
  def dob_m2
    self.date_of_birth_mm_dd_yyyy[1]
  end
  # /
  def dob_d1
    self.date_of_birth_mm_dd_yyyy[3]
  end
  def dob_d2
    self.date_of_birth_mm_dd_yyyy[4]
  end
  # /

  def dob_y1
    self.date_of_birth_mm_dd_yyyy[6]
  end
  def dob_y2
    self.date_of_birth_mm_dd_yyyy[7]
  end
  def dob_y3
    self.date_of_birth_mm_dd_yyyy[8]
  end
  def dob_y4
    self.date_of_birth_mm_dd_yyyy[9]
  end
  
  def dln_1
    self.license && self.license[0]
  end
  def dln_2
    self.license && self.license[1]
  end
  def dln_3
    self.license && self.license[2]
  end
  def dln_4
    self.license && self.license[3]
  end
  def dln_5
    self.license && self.license[4]
  end
  def dln_6
    self.license && self.license[5]
  end
  def dln_7
    self.license && self.license[6]
  end
  def dln_8
    self.license && self.license[7]
  end
  def dln_9
    self.license && self.license[8]
  end

  def voter_pin_1
    self.voter_pin && self.voter_pin[0]
  end
  def voter_pin_2
    self.voter_pin && self.voter_pin[1]
  end
  def voter_pin_3
    self.voter_pin && self.voter_pin[2]
  end
  def voter_pin_4
    self.voter_pin && self.voter_pin[3]
  end
  
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "Last Name Suffix": {
      method: "name_suffix"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Date of Birth - Month Digit 1": { method: "dob_m1" },
    "Date of Birth - Month Digit 2": { method: "dob_m2" },
    "Date of Birth - Day Digit 1": { method: "dob_d1" },
    "Date of Birth - Day Digit 2": { method: "dob_d2" },
    "Date of Birth - Year Digit 1": { method: "dob_y1" },
    "Date of Birth - Year Digit 2": { method: "dob_y2" },
    "Date of Birth - Year Digit 3": { method: "dob_y3" },
    "Date of Birth - Year Digit 4": { method: "dob_y4" },
    "Driver's LIcenese 1": { method: "dln_1" ,sensitive: true }, 
    "Driver's LIcenese 2": { method: "dln_2" ,sensitive: true},
    "Driver's LIcenese 3": { method: "dln_3" ,sensitive: true},
    "Driver's LIcenese 4": { method: "dln_4" ,sensitive: true},
    "Driver's LIcenese 5": { method: "dln_5" ,sensitive: true},
    "Driver's LIcenese 6": { method: "dln_6" ,sensitive: true},
    "Driver's LIcenese 7": { method: "dln_7" ,sensitive: true},
    "Driver's LIcenese 8": { method: "dln_8" ,sensitive: true},
    "Driver's LIcenese 9": { method: "dln_9" ,sensitive: true},
    "Four-Digit Voter PIN 1": { method: "voter_pin_1" },
    "Four-Digit Voter PIN 2": { method: "voter_pin_2" },
    "Four-Digit Voter PIN 3": { method: "voter_pin_3" },
    "Four-Digit Voter PIN 4": { method: "voter_pin_4" },
    "Home Street Address (include apt, lot, etc. if applicable)": {
      method: "address"
    },
    "Home Address City": {
      method: "city"
    },
    "Home Address Zip Code": {
      method: "zip"
    },
    "County": {},
    "Mail Address": {
      pdf_field: "Mail Address/P.O. Box"
    },
    "Mailing Address City": {},
    "Mailing Address State": {},
    "Mailing Address Zip Code": {},
    "Country (Other than US)": {},
    "Phone Number": {
      method: "phone"
    },
    "Email Address": {
      method: "email"
    },
    "Do not add this contact info to my voter recored check box": { 
      options: ["Off", "Yes"] 
    },
    "Election Date - Month Digit 1": {
      value: "1"
    },
    "Election Date - Month Digit 2": {
      value: "1"
    },
    "Election Date - Day Digit 1": {
      value: "0"
    },
    "Election Date - Day Digit 2": {
      value: "3"
    },
    "Election Date - Year Digit 1": {
      value: "2"
    },
    "Election Date - Year Digit 2": {
      value: "0"
    },
    "Election Date - Year Digit 3": {
      value: "2"
    },
    "Election Date - Year Digit 4": {
      value: "0"
    },
    "Election Type": { 
      options: ["City/School Election Type", "General Election Type", "Off", "Primary Election Type", "Special Election Type"],
      value:  "General Election Type"
    },
    "Political Party - Primary Election": { 
      options: ["Democratic Party", "Off", "Republican Party"],
      value: "Off"
    }
  }
  EXTRA_FIELDS = ["identification", "license", "voter_pin", "has_mailing_address"]
   
  def form_field_items
    [
      {"identification": {type: :radio, options: ["dln", "vic"]}},
      {"license": {visible: "identification_dln", min: 9, max: 9, regexp: /\A(\d{9}|\d{3}[[:alpha:]]{2}\d{4}\z/}},
      {"voter_pin": {visible: "identification_vic", min: 4, max: 4, regexp: /\A\d{4}\z/}},
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Adair",
        "Adams",
        "Allamakee",
        "Appanoose",
        "Audubon",
        "Benton",
        "Black Hawk",
        "Boone",
        "Bremer",
        "Buchanan",
        "Buena Vista",
        "Butler",
        "Calhoun",
        "Carroll",
        "Cass",
        "Cedar",
        "Cerro Gordo",
        "Cherokee",
        "Chickasaw",
        "Clarke",
        "Clay",
        "Clayton",
        "Clinton",
        "Crawford",
        "Dallas",
        "Davis",
        "Decatur",
        "Delaware",
        "Des Moines",
        "Dickinson",
        "Dubuque",
        "Emmet",
        "Fayette",
        "Floyd",
        "Franklin",
        "Fremont",
        "Greene",
        "Grundy",
        "Guthrie",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Harrison",
        "Henry",
        "Howard",
        "Humboldt",
        "Ida",
        "Iowa",
        "Jackson",
        "Jasper",
        "Jefferson",
        "Johnson",
        "Jones",
        "Keokuk",
        "Kossuth",
        "Lee",
        "Linn",
        "Louisa",
        "Lucas",
        "Lyon",
        "Madison",
        "Mahaska",
        "Marion",
        "Marshall",
        "Mills",
        "Mitchell",
        "Monona",
        "Monroe",
        "Montgomery",
        "Muscatine",
        "O'Brien",
        "Osceola",
        "Page",
        "Palo Alto",
        "Plymouth",
        "Pocahontas",
        "Polk",
        "Pottawattamie",
        "Poweshiek",
        "Ringgold",
        "Sac",
        "Scott",
        "Shelby",
        "Sioux",
        "Story",
        "Tama",
        "Taylor",
        "Union",
        "Van Buren",
        "Wapello",
        "Warren",
        "Washington",
        "Wayne",
        "Webster",
        "Winnebago",
        "Winneshiek",
        "Woodbury",
        "Worth",
        "Wright",
      ]}},
      {"Do not add this contact info to my voter recored check box": {type: :checkbox}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mail Address": {visible: "has_mailing_address"}}, #TODO- the text isn't working and there was a weird duplicate thing on the txt file.... remind me to ask you about that. 
      {"Mailing Address City": {visible: "has_mailing_address"}},
      {"Mailing Address State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Mailing Address Zip Code": {visible: "has_mailing_address"}},
      {"Country (Other than US)": {visible: "has_mailing_address"}},
    ]
  end

  
  def custom_form_field_validations
    if self.has_mailing_address == "1"
      [
        "Mailing Address State",
        "Mailing Address City",
        "Mail Address",
        "Mailing Address Zip Code",        
      ].each do |f|
        custom_validates_presence_of(f)
      end
    end    
    if self.identification == "dln"
      custom_validates_presence_of("license")
    end  
    if self.identification == "vic"
      custom_validates_presence_of("voter_pin")
    end  
  end
  
 
end