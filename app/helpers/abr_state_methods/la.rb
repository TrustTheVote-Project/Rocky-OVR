module AbrStateMethods::LA
  
  PDF_FIELDS = {

    #changing date_of_birth_mm_dd_yyyy
    'abr_date_of_birth_mm_dd_yyyy': {
      method: "date_of_birth_mm_dd_yyyy"
    },

    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    'abr_middle_initial': {:method=>"middle_initial"},
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_street_number": {method: "street_number"},	
    "abr_street_name": {method: "street_name"},
    "abr_unit": {method: "unit"},	
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    'abr_zip': {method: "zip"},
    
    #"abr_full_name": {method:"full_name"},
    #'abr_date_of_birth_yyyy':{ method: "date_of_birth_yyyy" },     

    "abr_county": {},
    'abr_check_mailing_address':{options: ["Off", "On"]},
    #"abr_absence_begin_date":{method:"absence_begin_date_string"},
    #"abr_absence_end_date":{method:"absence_end_date_string"},
    'abr_mailing_address_line_1': {method: 'insure_abr_mailing_address_line_1'},
    'abr_mailing_unit': {method: 'insure_abr_mailing_unit'},
    'abr_mailing_city':{method: 'insure_abr_mailing_city'},
    'abr_mailing_state_abbrev':{method: 'insure_abr_mailing_state_abbrev'},
    'abr_mailing_zip':{method: 'insure_abr_mailing_zip'},


    #changing abr_middle_name2
    'abr_mother_maiden': {
      method: "abr_mother_maiden_or_na",
      sensitive:true,
    },
    'abr_last_4_ssn':{sensitive: true},
    'abr_reason_selections':{options:["abr_reason1", "abr_reason2", "abr_reason3", "abr_reason4", "abr_reason5","abr_reason6","abr_reason7","abr_reason8","abr_reason9","abr_reason10","abr_reason11", "abr_reason12"]},
    'abr_application_type_selections':{options:["abr_application_type1", "abr_application_type2"]},
     'abr_absence_date_instructions':{},
    "abr_absence_begin_date":{method:"absence_begin_date_string", sensitive:true},
    "abr_absence_end_date":{method:"absence_end_date_string", sensitive:true},
    'abr_election_type_selections':{},
    'abr_election_type1':{method: "abr_election_type1_string"},
    'abr_election_type2':{method: "abr_election_type2_string"},
    'abr_assistant_check1':{},
    'abr_assistant_name':{},
    'abr_relationship1':{},
    
    
  }
  
  #EXTRA_FIELDS = ["hand_delivered_or_faxed", "abr_check_mailing_address","dln_soft_validation","reason","receipt_type", "mailing_address_1", "mailing_address_2", "fax_number"] 
  #EXTRA_FIELDS = ['abr_absence_begin_date_input','abr_absence_begin_date_input_mm','abr_absence_begin_date_input_dd','abr_absence_begin_date_input_yyyy','abr_absence_end_date_input', 'abr_absence_end_date_input_mm','abr_absence_end_date_input_dd','abr_absence_end_date_input_yyyy',
  #'abr_mailing_address_line_1_input',  'abr_mailing_city_input', 'abr_mailing_state_abbrev_input', 'abr_mailing_zip_input', 'abr_mailing_unit_input', 'abr_mother_maiden_input',
#'abr_election_type1_input', 'abr_election_type2_input']
  EXTRA_FIELDS = ['abr_absence_begin_date_input','abr_absence_begin_date_input_mm','abr_absence_begin_date_input_dd','abr_absence_begin_date_input_yyyy','abr_absence_end_date_input', 'abr_absence_end_date_input_mm','abr_absence_end_date_input_dd','abr_absence_end_date_input_yyyy',
  'abr_mailing_address_line_1_input',  'abr_mailing_city_input', 'abr_mailing_state_abbrev_input', 'abr_mailing_zip_input', 'abr_mailing_unit_input', 'abr_mother_maiden_input',
'abr_election_type2_input']

  def reason_already
    if self.reason === "already"
      return "On"
    end
    return "Off"
  end
  def reason_submitting
    if self.reason === "submitting"
      return "On"
    end
    return "Off"
  end
  def reason_homebound_submitting
    if self.reason === "homebound_submitting"
      return "On"
    end
    return "Off"
  end

  def email_if_email_receipt
    if self.receipt_type.to_s === "email"
      return self.email
    end
    return ''
  end
  def mailing_1_if_mail_receipt
    if self.receipt_type.to_s === "mail"
      return self.abr_check_mailing_address == "1"  ? self.mailing_address_1 : self.address
    end
    return ''
  end
  def mailing_2_if_mail_receipt
    if self.receipt_type.to_s === "mail"
      return self.abr_check_mailing_address == "1" ? self.mailing_address_2 : self.address_city_state_zip
    end
    return ''
  end
  def fax_if_fax_receipt
    if self.receipt_type.to_s === "fax"
      return self.fax_number
    end
    return ''
  end

  def receipt_type_email
    if self.receipt_type.to_s === "email"
      return "On"
    end
    return "Off"
  end
  def receipt_type_mail
    if self.receipt_type.to_s === "mail"
      return "On"
    end
    return "Off"
  end
  def receipt_type_fax
    if self.receipt_type.to_s === "fax"
      return "On"
    end
    return "Off"
  end

  
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Acadia",
        "Allen",
        "Ascension",
        "Assumption",
        "Avoyelles",
        "Beauregard",
        "Bienville",
        "Bossier",
        "Caddo",
        "Calcasieu",
        "Caldwell",
        "Cameron",
        "Catahoula",
        "Claiborne",
        "Concordia",
        "De Soto",
        "East Baton Rouge",
        "East Carroll",
        "East Feliciana",
        "Evangeline",
        "Franklin",
        "Grant",
        "Iberia",
        "Iberville",
        "Jackson",
        "Jefferson",
        "Jefferson Davis",
        "La Salle",
        "Lafayette",
        "Lafourche",
        "Lincoln",
        "Livingston",
        "Madison",
        "Morehouse",
        "Natchitoches",
        "Orleans",
        "Ouachita",
        "Plaquemines",
        "Pointe Coupee",
        "Rapides",
        "Red River",
        "Richland",
        "Sabine",
        "St. Bernard",
        "St. Charles",
        "St. Helena",
        "St. James",
        "St. John The Baptist",
        "St. Landry",
        "St. Martin",
        "St. Mary",
        "St. Tammany",
        "Tangipahoa",
        "Tensas",
        "Terrebonne",
        "Union",
        "Vermilion",
        "Vernon",
        "Washington",
        "Webster",
        "West Baton Rouge",
        "West Carroll",
        "West Feliciana",
        "Winn",
      ]}},

      {"abr_check_mailing_address": {type: :checkbox, options: ["Off", "On"]}},	


      {"abr_mailing_address_line_1_input": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit_input": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city_input": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev_input": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip_input": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

    #changing abr_middle_name2
    {'abr_mother_maiden_input': {}},
    {'abr_last_4_ssn':{}},
    {'abr_reason_selections':{type: :radio, required:true, options:["abr_reason1", "abr_reason2", "abr_reason3", "abr_reason4", "abr_reason5","abr_reason6","abr_reason7","abr_reason8","abr_reason9","abr_reason10","abr_reason11", "abr_reason12"]}},
    {'abr_absence_date_instructions':{type: :instructions, visible: "abr_reason_selections_abr_reason2"}},
    {"abr_absence_begin_date_input": {type: :date , required: :if_visible, visible: "abr_reason_selections_abr_reason2"}},
    {"abr_absence_end_date_input": {type: :date, required: :if_visible, visible: "abr_reason_selections_abr_reason2"}},

    {'abr_application_type_selections':{type: :radio, options:["abr_application_type1", "abr_application_type2"], visible: "abr_reason_selections_abr_reason1", required: :if_visible }},
 
    {'abr_election_type_selections':{type: :instructions}},
    #{'abr_election_type1_input':{type: :checkbox, options: ["Off", "On"]}},
    {'abr_election_type2_input':{type: :checkbox, options: ["Off", "On"]}},
    {'abr_assistant_check1':{type: :checkbox, options: ["Off", "On"]}},	
    {'abr_assistant_name':{required: :if_visible, visible: "abr_assistant_check1"}},
    {'abr_relationship1':{required: :if_visible, visible: "abr_assistant_check1"}},




    ]
  end
  #e.g.
  # [
  #   {"Security Number": {required: true}},
  #   {"State": {visible: "abr_check_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
  #   {"ZIP_2": {visible: "abr_check_mailing_address", min: 5, max: 10}},
  #   {"identification": {
  #     type: :radio,
  #     required: true,
  #     options: ["dln", "ssn4", "photoid"]}},
  #   {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
  #   {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/}},
  # ]
  
 #CTW new

 def custom_form_field_validations


  #if self.abr_election_type1_input.to_s=="0" && self.abr_election_type2_input.to_s=="0"
  # errors.add("abr_election_type2_input",  custom_required_message(:abr_election_type2_input))
  #end
  
  if self.abr_election_type2_input.to_s=="0"
   errors.add("abr_election_type2_input",  custom_required_message(:abr_election_type2_input))
  end

  if self.abr_reason_selections.to_s == "abr_reason2" && !self.test_date(self.absence_begin_date_string.to_s)
    errors.add("abr_absence_begin_date_input", custom_format_message("bad_date") )
    #errors.add('absence_begin_date_input', self.address_begindate_mm_dd_yyyy.to_s)
  end

  if self.abr_reason_selections.to_s == "abr_reason2" && !self.test_date(self.absence_end_date_string.to_s)
    errors.add("abr_absence_end_date_input", custom_format_message("bad_date") )
    #errors.add('absence_end_date_input', self.address_enddate_mm_dd_yyyy.to_s)
  end

 end

 def test_date(datestring)
  begin
    @mydate = Date.strptime(datestring, "%m/%d/%y")
    return true
  rescue ArgumentError
    return false
  end
end


  def date_field_string_mm_dd_yy(field_opts)
    d = date_field_value(field_opts)
    if d
      return d&.strftime("%m/%d/%y")
    end
    rescue
    nil
  end

  def absence_begin_date_string
    date_field_string_mm_dd_yy(method: :abr_absence_begin_date_input)
  end

  def absence_end_date_string
    date_field_string_mm_dd_yy(method: :abr_absence_end_date_input)
  end
  
  def abr_mother_maiden_or_na
    return  !self.abr_mother_maiden_input.blank? ? self.abr_mother_maiden_input.to_s : "N/A"
  end

  def abr_election_type2_string
    return "11/18/2023" if self.abr_election_type2_input.to_s == "1"
  end
  
  #def abr_election_type1_string
  #  return "12/10/2022" if self.abr_election_type1_input.to_s == "1"
  #end

  def  insure_abr_mailing_address_line_1
    return self.abr_check_mailing_address.to_s =="1" ? self.abr_mailing_address_line_1_input : self.address_line_1

  end

  def  insure_abr_mailing_unit
    return self.abr_check_mailing_address.to_s =="1" ? self.abr_mailing_unit_input : self.unit

  end

  def  insure_abr_mailing_city
    return self.abr_check_mailing_address.to_s =="1" ? self.abr_mailing_city_input : self.city
  end

  def  insure_abr_mailing_state_abbrev
    return self.abr_check_mailing_address.to_s =="1" ? self.abr_mailing_state_abbrev_input : self.home_state_abbrev
  end

  def  insure_abr_mailing_zip 
    return self.abr_check_mailing_address.to_s =="1" ? self.abr_mailing_zip_input : self.zip
  end
end


 

