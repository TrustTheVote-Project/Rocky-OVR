module AbrStateMethods::MI

  PDF_FIELDS = {

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
    "abr_full_name": {method:"full_name"},
    'abr_date_of_birth_yyyy':{ method: "date_of_birth_yyyy" },     

    'abr_check_mailing_address':{options: ["Off", "On"]},
    "abr_absence_begin_date":{method:"absence_begin_date_string"},
    "abr_absence_end_date":{method:"absence_end_date_string"},
    'abr_mailing_address_line_1': {},
    'abr_mailing_unit': {},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip':{},  
    
    "abr_county": {},
    "abr_address_type_selections": {options:["abr_address_type1","abr_address_type2"]},
    "abr_address_type3": {},
    "abr_election_type_selections": {options:["abr_election_type1","abr_election_type2","abr_election_type3","abr_election_type4"]},
    
    "abr_primary_type_selections1": {options:["abr_primary_type1","abr_primary_type2","abr_primary_type3"]},
    
    "abr_election_type5": {options: ["Off", "On"]},
    "abr_request_check":{options: ["Off", "On"]},
    "abr_request_name": {},
    "abr_assistant_info1": {method:"assist_birthdate_string"},
    "abr_assistant_address_line_1": {},

  }
  EXTRA_FIELDS = ['assist_birthdate', 'assist_birthdate_mm','assist_birthdate_dd','assist_birthdate_yyyy','abr_absence_begin_date_input','abr_absence_begin_date_input_mm','abr_absence_begin_date_input_dd','abr_absence_begin_date_input_yyyy','abr_absence_end_date_input', 'abr_absence_end_date_input_mm','abr_absence_end_date_input_dd','abr_absence_end_date_input_yyyy']


  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m %d  %y")
      return true
    rescue ArgumentError
      return false
    end
  end

  def form_field_items
      [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
          "Alcona",
          "Alger",
          "Allegan",
          "Alpena",
          "Antrim",
          "Arenac",
          "Baraga",
          "Barry",
          "Bay",
          "Benzie",
          "Berrien",
          "Branch",
          "Calhoun",
          "Cass",
          "Charlevoix",
          "Cheboygan",
          "Chippewa",
          "Clare",
          "Clinton",
          "Crawford",
          "Delta",
          "Dickinson",
          "Eaton",
          "Emmet",
          "Genesee",
          "Gladwin",
          "Gogebic",
          "Grand Traverse",
          "Gratiot",
          "Hillsdale",
          "Houghton",
          "Huron",
          "Ingham",
          "Ionia",
          "Iosco",
          "Iron",
          "Isabella",
          "Jackson",
          "Kalamazoo",
          "Kalkaska",
          "Kent",
          "Keweenaw",
          "Lake",
          "Lapeer",
          "Leelanau",
          "Lenawee",
          "Livingston",
          "Luce",
          "Mackinac",
          "Macomb",
          "Manistee",
          "Marquette",
          "Mason",
          "Mecosta",
          "Menominee",
          "Midland",
          "Missaukee",
          "Monroe",
          "Montcalm",
          "Montmorency",
          "Muskegon",
          "Newaygo",
          "Oakland",
          "Oceana",
          "Ogemaw",
          "Ontonagon",
          "Osceola",
          "Oscoda",
          "Otsego",
          "Ottawa",
          "Presque Isle",
          "Roscommon",
          "Saginaw",
          "St. Clair",
          "St. Joseph",
          "Sanilac",
          "Schoolcraft",
          "Shiawassee",
          "Tuscola",
          "Van Buren",
          "Washtenaw",
          "Wayne",
          "Wexford",
      ]}},
      {"abr_address_type_selections": {type: :radio, options:["abr_address_type1","abr_address_type2"], required: true}},
      {"abr_address_type3": { required: true}},

      {"abr_check_mailing_address": {type: :checkbox, options: ["Off", "On"]}},	
      {"abr_absence_begin_date_input": {type: :date , required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_absence_end_date_input": {type: :date, required: :if_visible, visible: "abr_check_mailing_address"}},

      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	


      {"abr_election_type_selections": {type: :radio, options:["abr_election_type1","abr_election_type2","abr_election_type3","abr_election_type4"] , required: true}},
      
      {"abr_primary_type_selections1": {type: :radio, options:["abr_primary_type1","abr_primary_type2","abr_primary_type3"] , required: :if_visible, visible: "abr_election_type1"}},
      
      
      {"abr_election_type5": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_request_check": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_request_name": { required: :if_visible, visible: "abr_request_check"}},
      {"assist_birthdate": {type: :date, required: :if_visible, visible: "abr_request_check"}},
      {"abr_assistant_address_line_1": {required: :if_visible, visible: "abr_request_check"}},

      ]
  end


  def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery



      if self.abr_request_check.to_s=="1" && !self.test_date(self.assist_birthdate_string.to_s)
       errors.add("assist_birthdate", custom_format_message("bad_date") )
      end

      if self.abr_check_mailing_address.to_s == "1" && !self.test_date(self.absence_begin_date_string.to_s)
        errors.add("abr_absence_begin_date_input", custom_format_message("bad_date") )
        #errors.add('absence_begin_date_input', self.address_begindate_mm_dd_yyyy.to_s)
      end

      if self.abr_check_mailing_address.to_s == "1" && !self.test_date(self.absence_end_date_string.to_s)
        errors.add("abr_absence_end_date_input", custom_format_message("bad_date") )
        #errors.add('absence_end_date_input', self.address_enddate_mm_dd_yyyy.to_s)
      end

  end

  def date_field_string_mm_dd_yy_l(field_opts)
    d = date_field_value(field_opts)
    if d
      return d&.strftime("%m  %d  %y")
    end
  rescue
    nil
  end

  def date_field_string_mm_dd_yy(field_opts)
    d = date_field_value(field_opts)
    if d
      return d&.strftime("%m %d %y")
    end
  rescue
    nil
  end

  def absence_begin_date_string
      date_field_string_mm_dd_yy_l(method: :abr_absence_begin_date_input)
  end

  def absence_end_date_string
    date_field_string_mm_dd_yy_l(method: :abr_absence_end_date_input)
  end

  def assist_birthdate_string
    date_field_string_mm_dd_yy(method: :assist_birthdate)
  end



end
