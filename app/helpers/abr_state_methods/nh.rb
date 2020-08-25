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

    #"Group1": {},
    #"Group2": {},
    #"Group2a": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "storm_warning"]
 
  
  def form_field_items
    [
      #{"reason_instructions": {type: :instructions}},
      {"absentee_reason":{type: :radio, options:['reason1','reason3','reason4','reason5', 'storm_warning'], required: true}},

      #{"Check Box14": {type: :checkbox, classes: "indent"}},
      #{"Check Box16": {type: :checkbox, classes: "indent"}},
      #{"Check Box17": {type: :checkbox, classes: "indent"}},
      #{"Check Box18": {type: :checkbox, classes: "indent"}},
      #{"storm_warning": {type: :checkbox}},
      {"storm_warning_reason":{type: :radio, options:['reason1','reason2'], visible: "absentee_reason_storm_warning", required: "star", classes: "indent"}},
      #{"Check Box19": {type: :checkbox, classes: "indent"}},
      #{"Check Box20": {type: :checkbox, classes: "indent"}},
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

  # Radio select

  # Methods below map from UI attributes to PDF fields
  def absentee_reasons
    {
      "reason1": self.class.make_method_name("Check Box14"),
      "reason3": self.class.make_method_name("Check Box16"),
      "reason4": self.class.make_method_name("Check Box17"),
      "reason5": self.class.make_method_name("Check Box18"),
      "storm_warning":"storm_warning"

    }
  
  end 
  
  def absentee_reason
    absentee_reasons.each do |k,m|
      return k if self.send(m) == "Yes"
    end
    return nil #otherwise implicit non-nil return of the absentee_reasons hash
  end
  
  def absentee_reason=(value)
    absentee_reasons.each do |k,m|
      if k.to_s == value.to_s
        self.send("#{m}=", "Yes")
        #if (k.to_s!='storm_warning')
        #    self.group2=k.to_s
        #end
      else
        self.send("#{m}=", "Off")
      end
    end    
  end

  def storm_warning_reasons
    {
      "reason1": self.class.make_method_name("Check Box19"),
      "reason2": self.class.make_method_name("Check Box20"),

    }
  end

  def storm_warning_reason
    storm_warning_reasons.each do |k,m|
      return k if self.send(m) == "Yes"
    end
    return nil #otherwise implicit non-nil return of the absentee_reasons hash
  end
  
  def storm_warning_reason=(value)
    storm_warning_reasons.each do |k,m|
      if k.to_s == value.to_s
        self.send("#{m}=", "Yes")
        #self.group2a=k.to_s
      else
        self.send("#{m}=", "Off")
      end
    end    
  end


  def custom_form_field_validations
    if absentee_reason.to_s=="storm_warning"
      custom_validates_presence_of("storm_warning_reason")
    end

       


  end
  
 
end