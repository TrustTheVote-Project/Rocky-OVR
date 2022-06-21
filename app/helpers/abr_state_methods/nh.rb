module AbrStateMethods::NH
  
PDF_FIELDS = {
  "abr_email": {method: "email"},	
  #"abr_phone": {method: "phone"},	
  "abr_first_name": {method: "first_name"},	
  "abr_middle_name":{method: "middle_name"},
  "abr_last_name": {method: "last_name"},	
  "abr_name_suffix": {method: "name_suffix"},	
  "abr_street_number": {method: "street_number"},	
  "abr_street_name": {method: "street_name"},	
  "abr_unit": {method: "unit"},	
  "abr_city": {method: "city"},	
  "abr_home_state_abbrev": {method: "home_state_abbrev"},	
  "abr_zip": {method: "zip"},	




#"abr_email":{},
"abr_email2":{method: "abr_email"},
#"abr_first_name":{},
#"abr_middle_name":{},
#"abr_last_name":{},
#"abr_name_suffix":{},
#"abr_street_number":{},
#"abr_street_name":{},
#"abr_unit":{},
#"abr_city":{},
#"abr_home_state_abbrev":{},
#"abr_zip":{},
"abr_county":{},
"abr_check_mailing_address":{},
"abr_mailing_address_line_1":{},
"abr_mailing_unit":{},
"abr_mailing_city":{},
"abr_mailing_state_abbrev":{},
"abr_mailing_zip":{},

"abr_form_instructions":{},
"abr_application_type_selections":{},
#"abr_application_type_selections":{},
#"abr_application_type_selections":{},
"abr_reason_selections":{options:['abr_reason1','abr_reason2','abr_reason3','abr_reason4','abr_reason5','abr_reason6']},
# "abr_reason_selections":{},
# "abr_reason_selections":{},
# "abr_reason_selections":{},
# "abr_reason_selections":{},
# "abr_reason_selections":{},
#"abr_reason6":{},
"abr_reason_6_selections":{ options:['abr_reason6_type1','abr_reason6_type2'] },
# "abr_application_type_selections":{},
# "abr_application_type_selections":{},
"abr_election_type_selections":{options: ['abr_election_type1','abr_election_type2','abr_election_type3','abr_election_type4']},
# "abr_election_type_selections":{},
# "abr_election_type_selections":{},
# "abr_election_type_selections":{},
# "abr_election_type_selections":{},
"abr_party_selections":{options:['abr_party1','abr_party2']},
# "abr_party_selections":{},
# "abr_party_selections":{},
"abr_election_date":{},
"abr_party_selections2":{options:['abr_party3','abr_party4']},
# "abr_party_selections2":{},
# "abr_party_selections2":{},
"abr_election_date2":{},
"abr_assistant_check1":{},
"abr_assistant_name":{},
"abr_phone":{ method: "phone_area"},
"abr_phone2":{method: "phone_prefix"},
"abr_phone3":{method: "phone_suffix"},}



EXTRA_FIELDS = ["abr_election_date_dd", "abr_election_date_mm", "abr_election_date_yyyy" ,
  "abr_election_date2_dd", "abr_election_date2_mm", "abr_election_date2_yyyy"   ]

#EXTRA_FIELDS = ["has_mailing_address", "assistant", "absentee_reason","storm_warning", "storm_warning_reason","mail_street_name", "mail_state", "mail_zip"]
 
  
  def form_field_items
    [

      {"abr_form_instructions":{type: :instructions}},
      {"abr_form_instructions2":{type: :instructions}},
      {"abr_application_type_selections":{type: :radio, options:['abr_application_type1','abr_application_type2'], required: true}},
      {"abr_reason_selections":{type: :radio, options:['abr_reason1','abr_reason2','abr_reason3','abr_reason4','abr_reason5','abr_reason6'], required: true}},
      {"abr_reason_6_selections":{type: :radio, visible: 'abr_reason_selections_abr_reason6', required: :if_visible, options:['abr_reason6_type1','abr_reason6_type2']}},

      {"abr_election_type_selections":{type: :radio, options:['abr_election_type1','abr_election_type2','abr_election_type3','abr_election_type4'], required: true}},


      {"abr_party_selections":{type: :radio, options:['abr_party1','abr_party2'], visible: "abr_election_type_selections_abr_election_type1",  required: :if_visible}},
      {"abr_party_selections2":{type: :radio, options:['abr_party3','abr_party4'], visible: "abr_election_type_selections_abr_election_type3",  required: :if_visible}},

      {"abr_election_date":{type: :date, visible: "abr_election_type_selections_abr_election_type3",  required: :if_visible}},
      {"abr_election_date2":{type: :date, visible: "abr_election_type_selections_abr_election_type4",  required: :if_visible}},


      {"abr_county":{}},

      {"abr_check_mailing_address": {type: :checkbox}},	


      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	



      
      {"abr_assistant_check1": {type: :checkbox}},
      {"abr_assistant_name": {visible: "abr_assistant_check1", required: :if_visible}},
    ]
  end

  def state_zip 
    if self.has_mailing_address.to_s=='1' 
      return self.mail_state.to_s() +' '+self.mail_zip.to_s() 
    end
  end

  def phone_area
    return if phone.blank?
    return phone.slice(0,2)
  end

  def phone_prefix
    return if phone.blank?
    return phone.slice(4,6)
  end

  def phone_suffix
    return if phone.blank?
    return phone.slice(8,11)
  end


 

  # Radio select

  # Methods below map from UI attributes to PDF fields




  def custom_form_field_validations

  end
  
 
end