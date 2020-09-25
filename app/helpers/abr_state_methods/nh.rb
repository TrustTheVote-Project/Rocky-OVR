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
 
    "Applicants_Phone": {
      method:"phone"
    }, 
    "email": {
      method:"email"
    },

    #"voter_signature": {}
    #"Date_Signed": {}
    #"assistant_signature": {}
    "Asisstant Name": {},

    "Group_I": {},
    "Group_II": {},


    "State_Primary": { options: ["Off", "Yes"],
      value: 'Off'},

    "State_General": { options: ["Off", "Yes"],
    value: "Yes" },
    
    "Party": {}
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant", "absentee_reason","storm_warning", "storm_warning_reason","mail_street_name", "mail_state", "mail_zip"]
 
  
  def form_field_items
    [
      {"Group_I": {type: :radio, options:['Choice1','Choice2'], required: true}},

      {"Group_II":{type: :radio, options:['Choice1','Choice2','Choice3','Choice4', 'Choice5'], required: true}},
       {"has_mailing_address": {type: :checkbox}},
      {"Street or PO Box": {visible: "has_mailing_address", classes: "quarter", }},
      {"mail_street_name": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      {"AptUnit_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"CityTown_2": {visible: "has_mailing_address", classes: "half", required: :if_visible}},
      #{"State Zip Code": {visible: "has_mailing_address", classes: "half last", required: :if_visible}},
      {"mail_state": {visible: "has_mailing_address", classes: "quarter ",required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true}},
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

 

  # Radio select

  # Methods below map from UI attributes to PDF fields




  def custom_form_field_validations

  end
  
 
end