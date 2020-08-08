module AbrStateMethods::OH
  
  def self.included(klass)
    klass.extend(AbrStateMethods::ClassMethods)
    klass.add_pdf_fields({
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
      "Date of Birth do not write todays date here": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Street Address no PO  boxes": {
        method: "address"
      },
      "County": {},
      "CityVillage": {
        method: "city"
      },
      "ZIP": {
        method: "zip"
      },
      #mailing address
      "Street Address or PO  box": {},
      "CityVillage_2": {},
      "State": {},
      "ZIP_2": {},
      "OR": {}, #drivers license number
      "Your Ohio driver license number 2 letters followed by 6 numbers": {
        options: ["Off", "On"]
      },
      "Last four digits of your Social Security number": {
        options: ["Off", "On"]
      },
      "Copy of a current and valid photo identification military identification or a current within the": {
        options: ["Off", "On"]
      },
      "OR_2": {}, #last 4 of SS
      "Date of Election do not write todays date here": {
        value: "11/03/2020"
      },
      "General Election": {
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
      "Email Address": {
        method: "email"
      },
    })
    klass.define_state_value_attribute("has_mailing_address")
    klass.define_state_value_attribute("identification")
  end
  
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
      {"Street Address or PO  box": {visible: "has_mailing_address"}},
      {"CityVillage_2": {visible: "has_mailing_address"}},
      {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
      {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"identification": {
        type: :radio, 
        required: true,
        options:["dln", "ssn4", "photoid"]}},
      {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
      {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/ }},      
    ]
  end
  
  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      ["Street Address or PO  box", "CityVillage_2", "State", "ZIP_2"].each do |f|
        errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
      end
    end
    if self.identification == "dln"
      f = "OR"
      errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
    end
    if self.identification == "ssn4"
      f = "OR_2"
      errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
    end
  end
  
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
  
 
end