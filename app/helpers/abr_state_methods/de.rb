module AbrStateMethods::DE
  
  PDF_FIELDS = {

    "BirthDate": {
      method: "date_of_birth_mm_dd_yyyy",
    },

    "Ballot Address Line 1": {},
    "Ballot Address Line 2": {},
    "Ballot Address Line 3": {},

 
    "First Name": {
      method: 'first_name'
    },
    "Suffix": {
      method: 'name_suffix'
    },
    "Middle Name or Initial":{
      method: 'middle_initial'
    },
    "Last Name": {
      method: 'last_name'
    },
    "House Number and Street Name": {
      method: 'address'
    },
    "City": {
      method: 'city'
    },
    "ZipCode":{
      method: 'zip'
    },

    "Political Party Affiliation": {},

    "Last4 Digits of SSN": {sensitive: true},
    "Email Address": {
      method: "email"
    },

    "Check box if you are Sick or Physically Disabled": {
      options: ["Off", "Yes"],
      method: "check_sick_or_disabled_yes"},
    "GroupSickDisabled": { options: ["ChoiceEmail", "ChoiceFax", "ChoiceMail"] },
    
    "Email Address_disabled": { # This is actually for disabled email delivery
      method: "email_if_choice_email"
    },
    "Fax": {},
    "Phone": {
      method: "phone"
    },

    "General Election": { 
      options: ["Off", "Yes"],
      value: "Yes" 
    },

    "All Elections": { options: ["Off", "Yes"],
      value: 'Off' 
    },
    "Any Election before 1/21/2020": { 
      options: ["Off", "Yes"],
      value: 'Off'
     },
     "Primary Election": {
       options: ["Off", "Yes"],
       value: 'Off'
    },
     #"Application Date": {}
    #"voter_signature": {}

  }
  
  EXTRA_FIELDS = ["has_mailing_address", "check_sick_or_disabled"]
  
  def form_field_items
    [
      {"Last4 Digits of SSN": {required: false, regexp: /\A\d{4}\z/}},
      {"has_mailing_address": {type: :checkbox}},
      {"Ballot Address Line 1": {visible: "has_mailing_address", required: :if_visible}},
      {"Ballot Address Line 2": {visible: "has_mailing_address", }},
      {"Ballot Address Line 3": {visible: "has_mailing_address",}},
      {"check_sick_or_disabled":{type: :checkbox}},
      {"GroupSickDisabled": {visible: "check_sick_or_disabled", type: :radio, required: :if_visible}},
      
      {"Fax": {visible: "groupsickdisabled_choicefax"}},
    
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
    if self.check_sick_or_disabled.to_s=='1' && self.groupsickdisabled.to_s=='ChoiceFax'
      custom_validates_presence_of("Fax")
    end
  end
  
  def check_sick_or_disabled_yes
    return "Yes" if self.check_sick_or_disabled.to_s=='1'
  end

  def email_if_choice_email
    return self.email if self.groupsickdisabled.to_s=='ChoiceEmail'
  end

end