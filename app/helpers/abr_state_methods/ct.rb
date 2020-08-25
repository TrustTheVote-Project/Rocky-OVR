module AbrStateMethods::CT
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name" 
    },
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Home Address": {
      method: "partial_address"
    }, #TODO- number, street, & city  #ToDone
    "Zip Code": {
      method: "zip"
    },
    "Telephone No": {
      method: "phone"
    },
    "Email Address": {
      method: "email"
    },
    "Mailing Address 1": {
      method: "full_name_conditional"
    },
    "Mailing Address 2": {},
    "Mailing Address 3": {},
    "COVID19  All voters are able to check this box pursuant to Executive Order 7QQ": { options: ["Off", "On"] },
    "My active service in the Armed Forces of the United States": { options: ["Off", "On"] },
    "My absence from the town during all of the hours of voting": { options: ["Off", "On"] },
    "My illness": { options: ["Off", "On"] },
    "My religious tenets forbid secular activity on the day of the election primary or referendum": { options: ["Off", "On"] },
    "My duties as a primary election or referendum official at a polling place other than my own during all of the hours of voting": { options: ["Off", "On"] },
    "My physical disability": { options: ["Off", "On"] },
    #"Date Signed": {},
    "Printed Name": {},
    "Tel No": {},
    "Residence Address": {},
    #"voter_signature": {},
    #"witness_signature": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "assistant"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address 2": {visible: "has_mailing_address", required: :if_visible}},
      {"Mailing Address 3": {visible: "has_mailing_address", required: :if_visible}},
      {"assistant": {type: :checkbox}},
      {"Printed Name": {visible: "assistant", required: :if_visible, classes: "half"}},
      {"Tel No": {visible: "assistant", required: :if_visible, classes: "half last"}},
      {"Residence Address": {visible: "assistant", required: :if_visible}},
#      {"reason_instructions": {type: :instructions}},
      {"absentee_reason": { type: :radio, options: [1,2,3,4,5,6,7], required: true}},
=begin
      {"COVID19  All voters are able to check this box pursuant to Executive Order 7QQ": {type: :checkbox}},
      {"My active service in the Armed Forces of the United States": {type: :checkbox}},
      {"My absence from the town during all of the hours of voting": {type: :checkbox}},
      {"My illness": {type: :checkbox}},
      {"My religious tenets forbid secular activity on the day of the election primary or referendum": {type: :checkbox}},
      {"My duties as a primary election or referendum official at a polling place other than my own during all of the hours of voting": {type: :checkbox}},
      {"My physical disability": {type: :checkbox}},
=end      
    ]
  end
  #e.g.
  # [
  #   {"reason_instructions": {type: :instructions}}, *"reason_instructions" does NOT get put into EXTRA_FIELDS
  #   {"County": {type: :select, required: true, include_blank: true, options: [
  #     "Adams",
  #   ]}},
  #   {"Security Number": {required: true}},
  #   {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
  #   {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
  #   {"identification": {
  #     type: :radio,
  #     required: true,
  #     options: ["dln", "ssn4", "photoid"]}},
  #   {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
  #   {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/}},
  # ]
  
  def include_non_nil(item)
      return (item ? item : '' )
  end

  def partial_address
    address='';
    address+= include_non_nil(self.street_number)
    address+= include_non_nil(self.street_name)
    address+= include_non_nil(self.unit)
    address+=","
    address+=self.city

    return (address)
  end

  def full_name_conditional
    if(self.has_mailing_address.to_s == "1")
      return self.full_name
    end
  end

  
  # Methods below map from UI attributes to PDF fields
  def absentee_reasons

  {
    "1": self.class.make_method_name("COVID19  All voters are able to check this box pursuant to Executive Order 7QQ"),
    "2": self.class.make_method_name("My active service in the Armed Forces of the United States"),
    "3": self.class.make_method_name("My absence from the town during all of the hours of voting"),
    "4": self.class.make_method_name("My illness"),
    "5": self.class.make_method_name("My religious tenets forbid secular activity on the day of the election primary or referendum"),
    "6": self.class.make_method_name("My duties as a primary election or referendum official at a polling place other than my own during all of the hours of voting"),
    "7": self.class.make_method_name("My physical disability"),
  }

  end 

  def absentee_reason
    absentee_reasons.each do |k,m|
      return k if self.send(m) == "On"
    end
    return nil #otherwise implicit non-nil return of the absentee_reasons hash
  end

  def absentee_reason=(value)
    absentee_reasons.each do |k,m|
      if k.to_s == value.to_s
        self.send("#{m}=", "On")
      else
        self.send("#{m}=", "Off")
      end
    end    
  end

  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery

  end

 
end