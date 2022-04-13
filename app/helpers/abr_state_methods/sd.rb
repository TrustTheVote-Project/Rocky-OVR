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
    "abr_check_mailing_address": {  options: ["Off", "Yes"] },	
    "abr_mailing_address_line_1": { },
    "abr_mailing_city_state": { },
    "abr_mailing_zip": { },	
    "abr_election_type_selections": { options: [
      "abr_election_type1",
      "abr_election_type2",
    ]},
    "abr_election_type3": { options: ["Off", "Yes"]},	
    "abr_election_type4": { options: ["Off", "Yes"]},	
    "abr_election_type5": { options: ["Off", "Yes"]},	
    "abr_election_type6": { options: ["Off", "Yes"]},	
    "abr_election_type7": { options: ["Off", "Yes"]},	
    "abr_application_type_check1": { options: ["Off", "Yes"]},	
    "abr_primary_type_selections1": { options: [
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
    "abr_request_check": { options: ["Off", "Yes"] },	
    "abr_assistant_first_name": { },	
    "abr_assistant_last_name": { },	
    "abr_assistant_phone": { },	
    "abr_assistant_address_line_1": { },	
    "abr_assistant_line_2": { },	
    "abr_assistant_address_city_state": { },
    "abr_assistant_zip": { },	
    "abr_phone": { method: "phone" },	
  }
  #EXTRA_FIELDS = ["has_mailing_address", "messenger", "uocava", "uocava_email"]
  
  
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
      {"abr_mailing_city_state": { visible: "abr_check_mailing_address", required: :if_visible }},
      {"abr_mailing_zip": { visible: "abr_check_mailing_address", required: :if_visible }},
      {"abr_election_type_selections": { required: true, type: :radio }},
      {"abr_election_type3": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type4": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type5": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type6": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_election_type7": { type: :checkbox, visible: "abr_election_type_selections_abr_election_type2" }},
      {"abr_application_type_check1": { type: :checkbox, visible: "abr_election_type4" }},
      {"abr_primary_type_selections1": { required: true, type: :radio, visible: "abr_election_type_selections_abr_election_type1"  }},
      {"abr_residency_requirements_instructions": {type: :instructions, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type6 abr_election_type7"}},
      {"abr_residency_requirements_selections1": { type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type6 abr_election_type7"}},
      {"abr_residency_requirements_selections2": { type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type6 abr_election_type7" }},
      {"abr_id_selections": { type: :radio }},
      {"abr_request_check": { type: :checkbox }},
      {"abr_assistant_first_name": { visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_last_name": { visible: "abr_request_check", required: :if_visible  }},
      {"abr_assistant_phone": { visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_address_line_1": { visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_line_2": { }},
      {"abr_assistant_address_city_state": { visible: "abr_request_check", required: :if_visible }},
      {"abr_assistant_zip": { visible: "abr_request_check", required: :if_visible }},
    ]
  end
  
  # "Box 14": { options: ["Off", "Yes"] }, # uocava_1 yes
  # "Box 15": { options: ["Off", "Yes"] }, # uocava_1 no
  def uocava_1
    if self.box_14 == "Yes"
      return "Yes"
    elsif self.box_15 == "Yes"
      return "No"
    end
    return nil
  end
  def uocava_1=(value)
    if value == "Yes"
      self.box_14 = "Yes"
      self.box_15 = "Off"
    elsif value == "No"
      self.box_14 = "Off"
      self.box_15 = "Yes"
    end
  end
  
  # "Box 16": { options: ["Off", "Yes"] }, # uocava_2 yes
  # "Box 17": { options: ["Off", "Yes"] }, # uocava_2 no
  def uocava_2
    if self.box_16 == "Yes"
      return "Yes"
    elsif self.box_17 == "Yes"
      return "No"
    end
    return nil
    
  end
  def uocava_2=(value)
    if value == "Yes"
      self.box_16 = "Yes"
      self.box_17 = "Off"
    elsif value == "No"
      self.box_16 = "Off"
      self.box_17 = "Yes"
    end
  end
  
  
  # "Box 18": { options: ["Off", "Yes"] }, # uocava_3 yes
  # "Box 19": { options: ["Off", "Yes"] }, # uocava_3 no
  def uocava_3
    if self.box_18 == "Yes"
      return "Yes"
    elsif self.box_19 == "Yes"
      return "No"
    end
    return nil
    
  end
  def uocava_3=(value)
    if value == "Yes"
      self.box_18 = "Yes"
      self.box_19 = "Off"
    elsif value == "No"
      self.box_18 = "Off"
      self.box_19 = "Yes"
    end
    
  end
  
  
  
  def email_if_military_opt_in
    if uocava == "1" && uocava_email == "Yes"
      email
    else
      nil
    end
  end
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end