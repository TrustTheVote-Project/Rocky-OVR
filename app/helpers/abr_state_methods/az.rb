module AbrStateMethods::AZ
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_initial": {method: "middle_initial"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_street_number": {method: "street_number"},	
    "abr_street_name": {method: "street_name"},	
    "abr_unit": {method: "unit"},	
    "abr_address": {method:"address"},
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    "abr_zip": {method: "zip"},
    'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },

    
    "abr_county": {},

    "abr_election_type_selections": {},
    "abr_party_selections": {options:[
      'abr_party1',
      'abr_party2',
      'abr_party3',
      'abr_party4',
    ]},

    'abr_check_mailing_address':{},
    'abr_mailing_address':{method: "mailing_address"},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip':{},
    'abr_id_selections':{
      options:[
        'abr_id_type1',
        'abr_id_type2',
        'abr_id_type3',
      ]
    },
    'abr_drivers_license': {sensitive:true},
    "abr_last_4_ssn": {sensitive:true},
    "abr_place_of_birth":{},

    'abr_id_selections_value':{method: 'identification_data'},

    "abr_independent_selections":{
      options: ["abr_independent_yes", "abr_independent_no"]
    },

    "abr_change_name":{method: "abr_check_change_name_formatter"},
    "abr_change_address":{method: "abr_check_change_address_formatter"},


    #voter_signature

  }

  def signature_pdf_field_name
    "voter_signature"
  end

  EXTRA_FIELDS = [  "abr_mailing_address_line_1", "abr_mailing_unit",  {name:"abr_drivers_license", sensitive:true}, "abr_place_of_birth", {name:"abr_last_4_ssn", sensitive:true}, "abr_check_change_address", "abr_check_change_name"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  def form_field_items
    [


      {"abr_election_type_selections": {type: :radio, options: ["abr_election_type1", "abr_election_type2", "abr_election_type3", "abr_election_type4"]}},
      {"abr_independent_instructions": {type: :instructions, hidden: 'abr_election_type_selections_abr_election_type4'}},
      {"abr_independent_selections": {type: :radio, hidden: 'abr_election_type_selections_abr_election_type4' , options: ["abr_independent_yes", "abr_independent_no"]}},

      {"abr_party_selections": {visible: "abr_independent_selections_abr_independent_yes", required: :if_visible, type: :radio, options: ["abr_party1", "abr_party2", "abr_party3", "abr_party4"]}},

      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Apache",
        "Cochise",
        "Coconino",
        "Gila",
        "Graham",
        "Greenlee",
        "La Paz",
        "Maricopa",
        "Mohave",
        "Navajo",
        "Pima",
        "Pinal",
        "Santa Cruz",
        "Yavapai",
        "Yuma"]}},

      {"abr_check_mailing_address": {type: :checkbox}},	

      {"abr_mailing_address_line_1": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

      {"abr_id_selections": {type: :radio, options: ["abr_id_type1", "abr_id_type2", "abr_id_type3"]}},
      {"abr_drivers_license": {visible: "abr_id_selections_abr_id_type1", required: :if_visible, ui_regexp:"^[a-zA-Z][0-9]{8}$|^[0-9]{9}$", min:8, max:9}},
      {"abr_last_4_ssn": {required:  :if_visible,  min:4, max:4, visible:"abr_id_selections_abr_id_type2"}},
      {"abr_place_of_birth": {required: :if_visible, min:1, visible: "abr_id_selections_abr_id_type3"}},

      {"abr_check_change_address": {type: :checkbox}},	
      {"abr_check_change_name": {type: :checkbox}},	




    ]
  end

  def identification_data
    case self.abr_id_selections
    when "abr_id_type1"
     return (self.abr_drivers_license)
    when "abr_id_type2"
      return (self.abr_last_4_ssn)
    when "abr_id_type3"
      return (self.abr_place_of_birth)
    else
      return "Missing identification"
    end
  end


  def mailing_address
    "#{abr_mailing_address_line_1}" + (abr_mailing_unit.blank? ? '' : ", #{abr_mailing_unit}")
  end
   
  def abr_check_change_address_formatter
    return abr_check_change_address ? "On": "Off"
  end

  def abr_check_change_name_formatter
    return abr_check_change_name ? "On": "Off"
  end
   
end