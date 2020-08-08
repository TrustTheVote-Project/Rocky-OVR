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
      #I'm not sure about this section - this is the select-one-of-these-3-options section
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
      {"has_mailing_address": {type: :checkbox}},
      {"Street Address or PO  box": {visible: "has_mailing_address"}},
      {"CityVillage_2": {visible: "has_mailing_address"}},
      #TODO- fill in state options
      {"State": {visible: "has_mailing_address", type: :select, }},
      {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
      #TODO- make this work
      {"identification": {
        type: :radio, 
        options:["dln", "ssn4", "photoid"]}},
      {"OR": {visible: "identification_dln", min: 8, max: 8}},
      {"OR_2": {visible: "identification_ssn4", min: 4, max: 4}},
      #TODO
      {"County": {}}
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end