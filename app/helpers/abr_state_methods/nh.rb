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
    #"Mailing Street name": {
     # pdf_field: "Street name",
    "Street name": {
      method:"mail_street_name"
    },
    "AptUnit_2": {},
    "CityTown_2": {},
    "State Zip Code": {
      method: "state_zip"
    },
    "Applicants Phone Number": {
      method:"phone_area"
    }, 
    "undefined": {
      method:"phone_prefix"
    }, 
    "undefined_2": {
      method:"phone_last4"
    },
=begin 
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
=end
    "Applicants Email Address": {
      method: "email"
    },
    #"voter_signature": {}
    #"Date_Signed": {}
    #"assistant_signature": {}
    "Asisstant Name": {},

    "Group1": {},
    "Group2": {
      method: "group2"
    },
    "Group2a": {
      method: "group2a"
    },
    "Group3": {},
    
    "Party": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "absentee_reason","storm_warning", "storm_warning_reason","mail_street_name", "mail_state", "mail_zip"]
 
  
  def form_field_items
    [
      {"Group1": {type: :radio, options:['absent','registered'], required: true}},

      {"absentee_reason":{type: :radio, options:['reason1','reason3','reason4','reason5', 'storm_warning'], required: true}},
      {"storm_warning_reason":{type: :radio, options:['reason1','reason2'], visible: "absentee_reason_storm_warning", required: "star", classes: "indent"}},
      {"Group3": {type: :radio,  options: ["State Primary" ,"State General" ],required:true}},
      {"Party": {type: :radio,  options:["Democratic",  "Republican"], required: "star", visible: "group3_state_primary",}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street or PO Box": {visible: "has_mailing_address", classes: "quarter", required: :if_visible}},
      {"mail_street_name": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      {"AptUnit_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"CityTown_2": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      #{"State Zip Code": {visible: "has_mailing_address", classes: "half last", required: :if_visible}},
      {"mail_state": {visible: "has_mailing_address", classes: "quarter ", length: 2,required: :if_visible}},
      {"mail_zip": {visible: "has_mailing_address", classes: "quarter last", length:5, regexp: /\A[0-9]{5}\z/, required: :if_visible}},

      
      {"assistant": {type: :checkbox}},
      {"Asisstant Name": {visible: "assistant", required: :if_visible}},
    ]
  end

  def state_zip 
    if self.has_mailing_address.to_s=='1' 
      return self.mail_state.to_s() +' '+self.mail_zip.to_s() 
    end
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

  # Radio select

  # Methods below map from UI attributes to PDF fields


  def group2 
    if self.absentee_reason!='storm_warning'
      return (self.absentee_reason.to_s)
    end
  end
 
  def group2a 
    if self.absentee_reason=='storm_warning'
      return (self.storm_warning_reason.to_s)
    end
  end


  def custom_form_field_validations
    if absentee_reason.to_s=="storm_warning"
      custom_validates_presence_of("storm_warning_reason")
    end
    if group3.to_s=="State Primary"
      custom_validates_presence_of("Party")
    end
  end
  
 
end