module AbrStateMethods::DE
  
  PDF_FIELDS = {'6 I am temporarily residing outside of the U S': {},
                'abr_full_name': {},
                'abr_party': {},
                'abr_address_line_1': {:method=>"address_line_1"},
                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                'date_of_birth_mm_dd_yyyy': {},
                'abr_ssn_number': {},
                'abr_email': {:method=>"email"},
                'abr_mailing_address': {},
                'address_line_2': {},
                'abr_phone': {},
                'abr_reason_selections': {},
                'abr_delivery_address_selections': {},
                'abr_fax_number': {},
                'make_pav': {},
                'signature_date': {},
                'abr_election_presidential_primary': {},
                'abr_election_primary': {},
                'abr_election_general': {},
                'abr_election_special': {},
                'abr_election_all': {}
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
