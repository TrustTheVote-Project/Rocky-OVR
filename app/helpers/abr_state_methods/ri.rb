module AbrStateMethods::RI
  
  PDF_FIELDS = {

    "abr_email": {method: "email"},
    "abr_phone": {method: "phone"},
    #"abr_first_name": {method: "first_name"},
    #'abr_middle_initial': {:method=>"middle_initial"},
    #"abr_last_name": {method: "last_name"},
    "abr_full_name": {method: "full_name"},
    #"abr_name_suffix": {method: "name_suffix"},
    "abr_street_number": {method: "street_number"},
    "abr_street_name": {method: "street_name"},
    "abr_unit": {method: "unit"},
    "abr_city": {method: "city"},
    "abr_home_state_abbrev": {method: "home_state_abbrev"},
    'abr_zip': {method: "zip"},
    'abr_check_mailing_address':{},
    'abr_date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },
    #'abr_delivery_address_selections': {options: ['abr_delivery_address_type1','abr_delivery_address_type2','abr_delivery_address_type3']},
    'abr_mailing_address_line_1': {},
    'abr_mailing_unit': {},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip': {},  
    'abr_reason1': {options:['Off','On']},
    'abr_reason2': {options:['Off','On'], method: 'not_reason1'},

    #'abr_reason_selections': {options: ['abr_reason1','abr_reason2','abr_reason3','abr_reason4']},
    'abr_mailing_address_line_2': {method: "abr_mailing_address_line_2"},

    # 'abr_application_type_check1': {options: ['Off','On']},
    #'abr_party_selections':{
    #  options: [
    #    'abr_party1',
    #    'abr_party2',
    #  ],
    #  'abr_party1': {method: "abr_party_selection1"},
    #  'abr_party2': {method: "abr_party_selection2"}
    #}
    # 'abr_request_check': {options: ['Off','On']},
  }
  EXTRA_FIELDS = []
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [

      #{'abr_delivery_address_selections': {type: :radio, options: ['abr_delivery_address_type1','abr_delivery_address_type2','abr_delivery_address_type3'], required: true}},
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},

      #{'abr_reason_selections':{type: :radio, options: ['abr_reason1','abr_reason2','abr_reason3','abr_reason4'], required: true}},
    
      {'abr_reason_instructions': {type: :instructions }},
      {'abr_reason1':{type: :checkbox, options: ['Off','On']}},
      {'abr_mailing_address_line_2': {visible: 'abr_reason1' }},
      
      # {'abr_application_type_check1':{type: :checkbox, options: ['Off','On']}},

      #{"abr_party_selections":{type: :radio, options:['abr_party1','abr_party2'], required: :if_visible}}
      # {'abr_request_check':{type: :checkbox, options: ['Off','On']}},
    ]
  end
  
# CTW: don't need these anymore because 1 step means there is no way for user to go back and change the check
# reveal of these fields
# Keeping this here for conversation w/Alex on potential multistep stuff elsewhere.

# def conditional_value(condition, value) 
#   return (condition ? value : "")
# end

# def conditional_field_value(condition_field, value_field)
#   return conditional_value(self.send(condition_field), self.send(value_field))
# end

# def conditional_mailing_address_line_1
#   return conditional_field_value(abr_delivery_address_selections_abr_delivery_address_type2, 'mailing_address_line_1')
# end

# def conditional_mailing_unit
#   return conditional_field_value(abr_delivery_address_selections_abr_delivery_address_type2, 'mailing_unit')
# end

# def conditional_mailing_city
#   return conditional_field_value(abr_delivery_address_selections_abr_delivery_address_type2, 'mailing_city')
# end

# def conditional_mailing_state_abbrev
#   return conditional_field_value(abr_delivery_address_selections_abr_delivery_address_type2, 'mailing_state_abbrev')
# end

# def conditional_mailing_zip
#   return conditional_field_value(abr_delivery_address_selections_abr_delivery_address_type2, 'mailing_zip')
# end 

# def conditional_abr_mailing_address_line_2
#   return conditional_value(self.send('abr_delivery_address_selections_abr_delivery_address_type2') && self.send('abr_reason_selections_abr_reason2'), self.send('abr_mailing_address_line_2'))
# end

def not_reason1
  return "On" if self.abr_reason1.to_s !="1"
end

  
  def custom_form_field_validations

  end
  
 
end
