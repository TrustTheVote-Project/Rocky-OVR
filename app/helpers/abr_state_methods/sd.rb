module AbrStateMethods::SD
  
  PDF_FIELDS = {
    "abr_email": { method: "email" },	
    "abr_first_name": { method: "first_name" },	
    "abr_middle_name": { method: "middle_name"  },	
    "abr_last_name": { method: "last_name"  },	
    "abr_name_suffix": { method: "name_suffix" },	
    "abr_address_line_1": { method: "address_line_1" },
    "abr_unit": { method: "address_line_2" },	
    "abr_address_city_state": { method: "address_city_state" },
    "abr_county": { },	
    "abr_zip": { method: "zip" },	
    "abr_check_mailing_address": {  options: ["Off", "On"] },	
    "abr_mailing_address_line_1": { },
    "abr_mailing_city_state": { method: "get_abr_mailing_city_state" },
    "abr_mailing_zip": { },	
    "abr_election_type_selections": { options: [
      "abr_election_type1",
      "abr_election_type2",
    ]},
    "abr_election_type1": { method: "abr_election_type_selections_is_abr_election_type1", options: ["Off", "On"]},
    "abr_election_type3": { options: ["Off", "On"]},	
    "abr_election_type4": { options: ["Off", "On"]},	
    "abr_election_type5": { options: ["Off", "On"]},	
    "abr_election_type6": { options: ["Off", "On"]},	
    "abr_election_type7": { options: ["Off", "On"]},	
    "abr_application_type_check1": { options: ["Off", "On"]},	
    "abr_primary_type_selection": { options: [
      "abr_primary_type1",
      "abr_primary_type2",
      "abr_primary_type3",
    ]},
    "abr_residency_requirements_selections1": { options: [
      "abr_residency_requirements_yes1",
      "abr_residency_requirements_no1",
    ]},
    "abr_residency_requirements_selections2": { options: [
      "abr_residency_requirements_yes2",
      "abr_residency_requirements_no2",
    ]},
    "abr_id_selections": { options: [
      "abr_id_type1",
      "abr_id_type2",
    ]},
    "abr_request_check": { options: ["Off", "On"] },	
    "abr_assistant_first_name": { },	
    "abr_assistant_last_name": { },	
    "abr_assistant_phone": { },	
    "abr_assistant_address_line_1": { },	
    "abr_assistant_line_2": { },	
    "abr_assistant_address_city_state": { method: "get_abr_assistant_address_city_state" },
    "abr_assistant_zip": { },	
    "abr_phone": { method: "phone" },	
  }
  EXTRA_FIELDS = ["abr_mailing_state", "abr_mailing_city", "abr_assistant_address_city", "abr_assistant_address_state"]
  
  def abr_election_type_selections_is_abr_election_type1
    if abr_election_type_selections_abr_election_type1 
      return "On"
    end
    return "Off"
  end

  def get_abr_mailing_city_state
    [abr_mailing_state, abr_mailing_city].join(', ')
  end

  def get_abr_assistant_address_city_state
    [abr_assistant_address_city, abr_assistant_address_state].join(', ')
  end
  
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Aurora",
        "Beadle",
        "Bennett",
        "Bon Homme",
        "Brookings",
        "Brown",
        "Brule",
        "Buffalo",
        "Butte",
        "Campbell",
        "Charles Mix",
        "Clark",
        "Clay",
        "Codington",
        "Corson",
        "Custer",
        "Davison",
        "Day",
        "Deuel",
        "Dewey",
        "Douglas",
        "Edmunds",
        "Fall River",
        "Faulk",
        "Grant",
        "Gregory",
        "Haakon",
        "Hamlin",
        "Hand",
        "Hanson",
        "Harding",
        "Hughes",
        "Hutchinson",
        "Hyde",
        "Jackson",
        "Jerauld",
        "Jones",
        "Kingsbury",
        "Lake",
        "Lawrence",
        "Lincoln",
        "Lyman",
        "McCook",
        "McPherson",
        "Marshall",
        "Meade",
        "Mellette",
        "Miner",
        "Minnehaha",
        "Moody",
        "Pennington",
        "Perkins",
        "Potter",
        "Roberts",
        "Sanborn",
        "Shannon",
        "Spink",
        "Stanley",
        "Sully",
        "Todd",
        "Tripp",
        "Turner",
        "Union",
        "Walworth",
        "Yankton",
        "Ziebach",
      ]}},
      {"abr_check_mailing_address": { type: :checkbox }},
      {"abr_mailing_address_line_1": { visible: "abr_check_mailing_address", required: :if_visible }},
      {"abr_mailing_city": {classes: "half", visible: "abr_check_mailing_address", required: :if_visible }},
      {"abr_mailing_state": {classes: "quarter", visible: "abr_check_mailing_address", required: :if_visible,
        type: :select, options: GeoState.collection_for_select
      }},
      {"abr_mailing_zip": {classes: "quarter", visible: "abr_check_mailing_address", required: :if_visible }},
      {"abr_election_type_selections": { required: true, type: :radio }},
      {"abr_election_type3": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type4": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type5": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type6": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type7": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type_hint": { type: :instructions, visible_any: "abr_election_type4 abr_election_type_selections_abr_election_type1" }},
      {"abr_application_type_check1": { type: :checkbox, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type4" }},
      {"abr_primary_type_selection": { type: :radio, visible: "abr_application_type_check1"  }},
      {"abr_residency_requirements_instructions": {type: :instructions, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type5 abr_election_type6"}},
      {"abr_residency_requirements_selections1": { type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type6 abr_election_type5"}},
      {"abr_residency_requirements_selections2": { type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type6 abr_election_type5" }},
      {"abr_id_selections": { type: :radio }},
      {"abr_request_check": { type: :checkbox }},
      {"abr_assistant_first_name": { classes: "half", visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_last_name": { classes: "half", visible: "abr_request_check", required: :if_visible  }},
      {"abr_assistant_phone": { visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_address_line_1": {classes: "three-quarter",  visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_line_2": { classes: "quarter", visible: "abr_request_check", }},
      {"abr_assistant_address_city": { classes: "half", visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_address_state": { classes: "quarter", visible: "abr_request_check", required: :if_visible,
        type: :select, options: GeoState.collection_for_select
      }},
      {"abr_assistant_zip": { classes: "quarter", visible: "abr_request_check", required: :if_visible }},
    ]
  end
  
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end