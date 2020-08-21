module AbrStateMethods::NH
  
  PDF_FIELDS = {
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Jr Sr IIIII": {
      method: "name_suffix"
    },
    "Street Number": {
      method: "street_number"
    },
    "Street Name": {
      method: "street_name"
    },
    "AptUnit": {
      method: "unit"
    },
    "CityTown": {
      method: "city"
    },
    "Ward": {}, #TODO- automatically fill in a voter's ward (precinct) based on address?
    "Zip Code": {
      method: "zip"
    },
    "Street or PO Box": {},
    "Mailing Street name": {
      pdf_field: "Street name"
    },
    "AptUnit_2": {},
    "CityTown_2": {},
    "State Zip Code": {},
    "Applicants Phone Number": {
      method:"phone_area"
    }, 
    "undefined": {
      method:"phone_prefix"
    }, 
    "undefined_2": {
      method:"phone_last4"
    }, 
    "Check Box12": { 
      options: ["Off", "Yes"],
      value: "Yes"
     },
    "Check Box13": { 
      options: ["Off", "Yes"],
      value: "Yes"
    },
    "Check Box14": { options: ["Off", "Yes"] },
    "Check Box15": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Check Box16": { options: ["Off", "Yes"] },
    "Check Box17": { options: ["Off", "Yes"] },
    "Check Box18": { options: ["Off", "Yes"] },
    "Check Box19": { options: ["Off", "Yes"] },
    "Check Box20": { options: ["Off", "Yes"] },
    "Check Box21": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Check Box22": { 
      options: ["Off", "Yes"],
      value: "Yes"
    },
    "Applicants Email Address": {
      method: "email"
    },
    #"voter_signature": {}
    #"Date_Signed": {}
    #"assistant_signature": {}
    "Asisstant Name": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "storm_warning"]
 
  
  def form_field_items
    [
      {"reason_instructions": {type: :instructions}},
      {"Check Box14": {type: :checkbox, classes: "indent"}},
      {"Check Box16": {type: :checkbox, classes: "indent"}},
      {"Check Box17": {type: :checkbox, classes: "indent"}},
      {"Check Box18": {type: :checkbox, classes: "indent"}},
      {"storm_warning": {type: :checkbox}},
      {"Check Box19": {type: :checkbox, classes: "indent"}},
      {"Check Box20": {type: :checkbox, classes: "indent"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street or PO Box": {visible: "has_mailing_address", classes: "quarter", required: :if_visible}},
      {"Mailing Street name": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      {"AptUnit_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"CityTown_2": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      {"State Zip Code": {visible: "has_mailing_address", classes: "half last", required: :if_visible}},
      {"assistant": {type: :checkbox}},
      {"Asisstant Name": {visible: "assistant", required: :if_visible}},
    ]
  end

  def phone_area
    if self.phone.to_s!=''   
      return (phone_digits[0..2])
    end
  end

  def phone_prefix
    if self.phone.to_s!=''
      return (phone_digits[3..5])
    end
  end
  
  def phone_last4
    if self.phone.to_s!=''
      return (phone_digits[6..9])
    end
  end 

  def custom_form_field_validations

  end
  
 
end