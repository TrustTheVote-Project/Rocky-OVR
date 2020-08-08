module AbrStateMethods::WY
  
  def self.included(klass)
    klass.extend(AbrStateMethods::ClassMethods)
    klass.add_pdf_fields({
      "LAST NAME": {
        method: "last_name"
      },
      "FIRST NAME": {
        method: "first_name"
      },
      "MIDDLE": {
        method: "middle_name"
      },
      
      "COUNTY RESIDENTIAL ADDRESS": {
        method: "address"
      },
      "CITY": {
        method: "city"
      },
      "STATE": {
        method: "home_state_abbrev"
        #prefill with WY state abbrev?
      },
      "ZIP": {
        method: "zip"
      },
      "DATE OF BIRTH": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "CONTACT PHONE NUMBER": {
        method: "phone"
      },
      "ACTIVE MILITARY Y  N": {
        #whaaat
      },
      "EMAIL optional": {
        method: "email"
      },
      "MAIL MY BALLOT TO": {},
      "CITY_2": {},
      "STATE_2": {},
      "ZIP_2": {},
      "2020 PRIMARY": {
        options: ["Off", "On"],
        value: "Off"
      },
      "2020 GENERAL": {
        options: ["Off", "On"],
        value: "On"
      },
      "Individual's name who may pick up my ballot": {},
      #Date
      #voter_signature
    })
    klass.define_state_value_attribute("has_mailing_address")
  end
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"MAIL MY BALLOT TO": {visible: "has_mailing_address"}},
      {"CITY_2": {visible: "has_mailing_address"}},
      #TODO- fill in state options
      {"STATE_2": {visible: "has_mailing_address", type: :select, }},
      {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"ACTIVE MILITARY Y  N": {required: true, type: :radio, options: ["Y", "N"]}},
      {"Individual's name who may pick up my ballot": {}},
    ]
  end
  
  #attr_reader :has_mailing_address
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
  
end