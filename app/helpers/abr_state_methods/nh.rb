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
    }, #TODO- first 3 digits of phone number (area code) #TODONE
    "undefined": {
      method:"phone_prefix"
    }, #TODO- next 3 digits of phone number #TODONE
    "undefined_2": {
      method:"phone_last4"
    }, #TODO- last 4 digits of phone number #TODONE
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
      {"Street or PO Box": {visible: "has_mailing_address", classes: "quarter"}},
      {"Mailing Street name": {visible: "has_mailing_address", classes: "half"}},
      {"AptUnit_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"CityTown_2": {visible: "has_mailing_address", classes: "half"}},
      {"State Zip Code": {visible: "has_mailing_address", classes: "half last"}},
      {"assistant": {type: :checkbox}},
      {"Asisstant Name": {visible: "assistant"}},
    ]
  end

  def phone_area
    if self.phone.to_s!=''   
      phonedigits = self.phone.to_s.gsub(/\D/,'')
      return (phonedigits[0..2])
    end
  end

  def phone_prefix
    if self.phone.to_s!=''
      phonedigits = self.phone.to_s.gsub(/\D/,'')
      return (phonedigits[3..5])
    end
  end
  
  def phone_last4
    if self.phone.to_s!=''
      phonedigits =self.phone.to_s.gsub(/\D/,'')
      return (phonedigits[6..9])
    end
  end 

  def custom_form_field_validations

  end
  
 
end