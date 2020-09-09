module AbrStateMethods::OH
  
  PDF_FIELDS = {
    "First": {
      method: "first_name"
    },
    "Middle": {
      method: "middle_name"
    },
    "Last": {
      method: "last_name"
    },
    "Suffix": {
      method: "name_suffix"
    },
    "DOB_day": {
      method:"date_of_birth_mm"  # Note this is reversed in form
    },
    "DOB_mo": {
      method: "date_of_birth_dd" # Note this is reversed in form
    },
    "DOB_yr": {
      method: "date_of_birth_yyyy"
    },
    "Street Address": {
      method: "address"
    },
    "County": {},
    "City": {},
    "ZIP": {
      method: "zip"
    },
    "Street Address or PO Box": {},
    "City_2": {},
    "State": {},
    "ZIP_2": {},
    "Ohio_driver_license": {sensitive: true},
    
    "SSN4": {sensitive: true},
    "Date of Election do not write todays date here": {
      value: "11/03/2020"
    },
    "November General Election": {
      options: ["Off", "On"],
      value: "On"
    },
    
    "Primary Election": {
      options: ["Off", "On"],
      value: "Off"
    },
    "Special Election": {
      options: ["Off", "On"],
      value: "Off"
    },
    #Signature X
    #Todays Date
    "Telephone Number": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
  }
  
  EXTRA_FIELDS = ["has_mailing_address", "identification","dln_soft_validation"]

  
  def form_field_items
    [
      # from https://www.alphalists.com/list/alphabetical-list-ohio-counties
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Adams",
        "Allen",
        "Ashland",
        "Ashtabula",
        "Athens",
        "Auglaize",
        "Belmont",
        "Brown",
        "Butler",
        "Carroll",
        "Champaign",
        "Clark",
        "Clermont",
        "Clinton",
        "Columbiana",
        "Coshocton",
        "Crawford",
        "Cuyahoga",
        "Darke",
        "Defiance",
        "Delaware",
        "Erie",
        "Fairfield",
        "Fayette",
        "Franklin",
        "Fulton",
        "Gallia",
        "Geauga",
        "Greene",
        "Guernsey",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Harrison",
        "Henry",
        "Highland",
        "Hocking",
        "Holmes",
        "Huron",
        "Jackson",
        "Jefferson",
        "Knox",
        "Lake",
        "Lawrence",
        "Licking",
        "Logan",
        "Lorain",
        "Lucas",
        "Madison",
        "Mahoning",
        "Marion",
        "Medina",
        "Meigs",
        "Mercer",
        "Miami",
        "Monroe",
        "Montgomery",
        "Morgan",
        "Morrow",
        "Muskingum",
        "Noble",
        "Ottawa",
        "Paulding",
        "Perry",
        "Pickaway",
        "Pike",
        "Portage",
        "Preble",
        "Putnam",
        "Richland",
        "Ross",
        "Sandusky",
        "Scioto",
        "Seneca",
        "Shelby",
        "Stark",
        "Summit",
        "Trumbull",
        "Tuscarawas",
        "Union",
        "Van Wert",
        "Vinton",
        "Warren",
        "Washington",
        "Wayne",
        "Williams",
        "Wood",
        "Wyandot",
      ]}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street Address or PO Box": {visible: "has_mailing_address"}},
      {"City_2": {visible: "has_mailing_address"}},
      {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"identification": {
        type: :radio, 
        required: true,
        options:["dln", "ssn4", "photoid"]}},
      {"Ohio_driver_license": {visible: "identification_dln", required: "show_star", min: 8, max: 8, ui_regexp: "^[a-zA-Z]{2}[0-9]{6}$"}},
      {"SSN4": {visible: "identification_ssn4", required: "show_star",  min: 4, max: 4, regexp: /\A\d{4}\z/ }},      
      {"dln_soft_validation": {type: :hidden}},
    ]
  end
  
  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      ["Street Address or PO Box", "City_2", "State", "ZIP_2"].each do |f|
        custom_validates_presence_of(f)
      end
    end
    if self.identification == "dln"
      custom_validates_presence_of("Ohio_driver_license")
    end
    if self.identification == "ssn4"
      custom_validates_presence_of("SSN4")
    end
  end

end