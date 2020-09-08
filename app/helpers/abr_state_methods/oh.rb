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
    # Old "Date of Birth do not write todays date here": {
    #  method: "date_of_birth_mm_dd_yyyy"
    #},
    "DOB_day": {
      method:"date_of_birth_mm"  # Note this is reversed in form
    },
    "DOB_mo": {
      method: "date_of_birth_dd" # Note this is reversed in form
    },
    "DOB_yr": {
      method: "date_of_birth_yyyy"
    },
    #"Street Address no PO  boxes": {
    "Street Address": {
      method: "address"
    },
    "County": {},
    # Old "CityVillage": {
    #  method: "city"
    #},
    "City": {},
    "ZIP": {
      method: "zip"
    },
    #mailing address
    #old "Street Address or PO  box": {},
    "Street Address or PO Box": {},
    # old "CityVillage_2": {},
    "City_2": {},
    "State": {},
    "ZIP_2": {},
    #"OR": {sensitive: true}, #drivers license number
    "Ohio_driver_license": {sensitive: true},
    
=begin  
     "Your Ohio driver license number 2 letters followed by 6 numbers": {
      options: ["Off", "On"]
    },
    "Last four digits of your Social Security number": {
   
      options: ["Off", "On"]
    },
    "Copy of a current and valid photo identification military identification or a current within the": {
      options: ["Off", "On"]
    },
=end
    #"OR_2": {sensitive: true}, #last 4 of SS
    "SSN4": {sensitive: true},
    "Date of Election do not write todays date here": {
      value: "11/03/2020"
    },
    #old "General Election": {
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
        #errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
      end
    end
    if self.identification == "dln"
      custom_validates_presence_of("Ohio_driver_license")
      # f = "OR"
      # errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
    end
    if self.identification == "ssn4"
      custom_validates_presence_of("SSN4")
      # f = "OR_2"
      # errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
    end
  end
=begin
  def identification
    return "dln" if self.send(self.class.make_method_name("Your Ohio driver license number 2 letters followed by 6 numbers")) == "On"
    return "ssn4" if self.send(self.class.make_method_name("Last four digits of your Social Security number")) == "On"
    return "photoid" if self.send(self.class.make_method_name("Copy of a current and valid photo identification military identification or a current within the")) == "On"
  end
  
  def identification=(val)
    self.send(self.class.make_method_name("Your Ohio driver license number 2 letters followed by 6 numbers="), "Off")
    self.send(self.class.make_method_name("Last four digits of your Social Security number="), "Off")
    self.send(self.class.make_method_name("Copy of a current and valid photo identification military identification or a current within the="), "Off")
    if val == "dln"
      self.send(self.class.make_method_name("Your Ohio driver license number 2 letters followed by 6 numbers="), "On")
    elsif val == "ssn4"
      self.send(self.class.make_method_name("Last four digits of your Social Security number="), "On")
    elsif val == "photoid"
      self.send(self.class.make_method_name("Copy of a current and valid photo identification military identification or a current within the="), "On")
    end
  end
=end
 
end