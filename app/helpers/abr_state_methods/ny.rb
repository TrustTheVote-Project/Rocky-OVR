module AbrStateMethods::NY
  
  COUNTIES = [
    "Albany County",
    "Allegany County",
    "Bronx County",
    "Broome County",
    "Cattaraugus County",
    "Cayuga County",
    "Chautauqua County",
    "Chemung County",
    "Chenango County",
    "Clinton County",
    "Columbia County",
    "Cortland County",
    "Delaware County",
    "Dutchess County",
    "Erie County",
    "Essex County",
    "Franklin County",
    "Fulton County",
    "Genesee County",
    "Greene County",
    "Hamilton County",
    "Herkimer County",
    "Jefferson County",
    "Kings County (Brooklyn)",
    "Lewis County",
    "Livingston County",
    "Madison County",
    "Monroe County",
    "Montgomery County",
    "Nassau County",
    "New York County (Manhattan)",
    "Niagara County",
    "Oneida County",
    "Onondaga County",
    "Ontario County",
    "Orange County",
    "Orleans County",
    "Oswego County",
    "Otsego County",
    "Putnam County",
    "Queens County",
    "Rensselaer County",
    "Richmond County (Staten Island)",
    "Rockland County",
    "Saint Lawrence County",
    "Saratoga County",
    "Schenectady County",
    "Schoharie County",
    "Schuyler County",
    "Seneca County",
    "Steuben County",
    "Suffolk County",
    "Sullivan County",
    "Tioga County",
    "Tompkins County",
    "Ulster County",
    "Warren County",
    "Washington County",
    "Wayne County",
    "Westchester County",
    "Wyoming County",
    "Yates County",
  ]

  PDF_FIELDS = {'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_initial': {:method=>"middle_initial"},
                'abr_name_suffix': {:method=>"name_suffix"},
                'abr_date_of_birth_complete': {},
                'abr_county': {:method=>"county"},
                'abr_phone': {},
                'abr_email': {:method=>"email"},
                'abr_address_line_1': {:method=>"address_line_1"},
                'abr_address_line_2': {},
                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                'abr_reason_selections': {},
                'abr_election_type_selections': {},
                'abr_absence_begin_date': {},
                'abr_absence_end_date': {},
                'abr_mailing_unit': {:method=>"unit"},
                'abr_mailing_city': {:method=>"city"},
                'abr_mailing_state_abbrev': {:method=>"home_state_abbrev"},
                'abr_mailing_zip': {:method=>"zip"},
                'abr_request_name': {},
                'abr_assistant_address_line1': {},
                'abr_assistant_address_line2': {},
                'abr_address_type_selections': {},
                'abr_address_type_selections2': {},
                'abr_mailing_street_number': {},
                'abr_mailing_street_number1': {},
                'abr_mailing_street_name': {},
                'abr_mailing_street_name1': {},
                'abr_mailing_unit1': {},
                'abr_mailing_city1': {},
                'abr_mailing_state_abbrev1': {},
                'abr_mailing_zip1': {},
                'Name of Voter:': {},
                'Date (Applicant Marked)': {},
                'Date (Applicant Signed)': {},
                'delegate_name': {}
               }

  EXTRA_FIELDS = ["absence_begin_date_mm", "absence_begin_date_dd", "absence_begin_date_yyyy",
    "absence_end_date_mm", "absence_end_date_dd", "absence_end_date_yyyy",
  "primary_registration_address_check", "general_registration_address_check"]
  
  
  def form_field_items
    [
      {"abr_reason_instructions": {type: :instructions}},
    ]
  end
  
  def absence_begin_date_string
    date_field_string_mm_dd_yyyy(method: :absence_begin_date)
  end
  def absence_end_date_string
    date_field_string_mm_dd_yyyy(method: :absence_end_date)
  end

  def custom_form_field_validations  
  end


  def abr_mailing_street_number
    self.primary_registration_address_check == "1" ? street_number : get_attribute(:abr_mailing_street_number)
  end
  def abr_mailing_street_number=(value)
    set_attribute(:abr_mailing_street_number, value)
  end
  def abr_mailing_street_name
    self.primary_registration_address_check == "1" ? street_name : get_attribute(:abr_mailing_street_name)
  end
  def abr_mailing_street_name=(value)
    set_attribute(:abr_mailing_street_name, value)
  end
  def abr_mailing_unit
    self.primary_registration_address_check == "1" ? unit : get_attribute(:abr_mailing_unit)
  end
  def abr_mailing_unit=(value)
    set_attribute(:abr_mailing_unit, value)
  end
  def abr_mailing_city
    self.primary_registration_address_check == "1" ? city : get_attribute(:abr_mailing_city)
  end
  def abr_mailing_city=(value)
    set_attribute(:abr_mailing_city, value)
  end
  def abr_mailing_state_abbrev
    self.primary_registration_address_check == "1" ? home_state_abbrev : get_attribute(:abr_mailing_state_abbrev)
  end
  def abr_mailing_state_abbrev=(value)
    set_attribute(:abr_mailing_state_abbrev, value)
  end
  def abr_mailing_zip
    self.primary_registration_address_check == "1" ? zip : get_attribute(:abr_mailing_zip)
  end
  def abr_mailing_zip=(value)
    set_attribute(:abr_mailing_zip, value)
  end

  def abr_mailing_street_number1
    self.general_registration_address_check == "1" ? street_number : get_attribute(:abr_mailing_street_number1)
  end
  def abr_mailing_street_number1=(value)
    set_attribute(:abr_mailing_street_number1, value)
  end
  def abr_mailing_street_name1
    self.general_registration_address_check == "1" ? street_name : get_attribute(:abr_mailing_street_name1)
  end
  def abr_mailing_street_name1=(value)
    set_attribute(:abr_mailing_street_name1, value)
  end
  def abr_mailing_unit1
    self.general_registration_address_check == "1" ? unit : get_attribute(:abr_mailing_unit1)
  end
  def abr_mailing_unit1=(value)
    set_attribute(:abr_mailing_unit1, value)
  end
  def abr_mailing_city1
    self.general_registration_address_check == "1" ? city : get_attribute(:abr_mailing_city1)
  end
  def abr_mailing_city1=(value)
    set_attribute(:abr_mailing_city1, value)
  end
  def abr_mailing_state_abbrev1
    self.general_registration_address_check == "1" ? home_state_abbrev : get_attribute(:abr_mailing_state_abbrev1)
  end
  def abr_mailing_state_abbrev1=(value)
    set_attribute(:abr_mailing_state_abbrev1, value)
  end
  def abr_mailing_zip1
    self.general_registration_address_check == "1" ? zip : get_attribute(:abr_mailing_zip1)
  end
  def abr_mailing_zip1=(value)
    set_attribute(:abr_mailing_zip1, value)
  end
  
  
 
end
