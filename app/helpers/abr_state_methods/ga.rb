module AbrStateMethods::GA
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_name": {method: "middle_name"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_first_name2": {method: "first_name"},	
    "abr_middle_name2": {method: "middle_name"},	
    "abr_last_name2": {method: "last_name"},	
    "abr_name_suffix2": {method: "name_suffix"},	
    "abr_address_line_1": {method: "address"},
    "abr_city": {method: "city"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    "abr_zip": {method: "zip"},	
    "abr_county": {},	
    "abr_check_mailing_address": {options: ["Off", "Yes"]},	
    "abr_mailing_address_line_1": {},
    "abr_mailing_city": {},	
    "abr_mailing_state_name": {},	
    "abr_mailing_zip": {},
    "abr_id_type": {options: ["abr_id_type1", "abr_id_type2"]},	
    "abr_drivers_license": {sensitive: true},	
    "abr_date_of_birth_mm_dd_yyyy": {
      pdf_name: "date_of_birth_mm_dd_yyyy",
      method: "date_of_birth_mm_dd_yyyy"
    },	
    "abr_id_instructions": {},	
    "abr_election_type_selections": {method: "abr_election_date"},
    "abr_election_type_selections_options": {
      options: [
        #"abr_election_type1",
        #"abr_election_type3",
        #"abr_election_type2",
        "abr_election_type4",
      ]
    },	
    "abr_primary_type_selections1": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3",        
      ]
    },	
    "abr_assistant_check1": {options: ["Off", "Yes"]},
    "abr_assistant_instructions": {},
    "abr_assistant_name": {},
    "abr_request_instructions": {},	
    "abr_request_check": {options: ["Off", "Yes"]},	
    "abr_request_selections": {
      options: [
        "abr_request_type1",
        "abr_request_type2",
      ]
    },
    "abr_relationship1": {},	
    "abr_application_type_check1": {options: ["Off", "Yes"]},	
    "abr_application_type_selections": {
      options: [
        "abr_application_type1",
        "abr_application_type2",        
      ]
    },	
    "abr_phone": {method: "phone"},	    
  }


  def abr_election_date
    if self.abr_election_type_selections_options == "abr_election_type1"
      return "05/24/2022"
    elsif self.abr_election_type_selections_options == "abr_election_type3"
      return "06/21/2022"
    elsif self.abr_election_type_selections_options == "abr_election_type2"
      return "11/08/2022"
    elsif  self.abr_election_type_selections_options == "abr_election_type4"
      return "12/06/2022"
    end
    return ""
  end
  
  EXTRA_FIELDS = [""] 
  
  def form_field_items
    [
      {"abr_county": {type: :select, include_blank: true, options: [
        "Appling County",
        "Atkinson County",
        "Bacon County",
        "Baker County",
        "Baldwin County",
        "Banks County",
        "Barrow County",
        "Bartow County",
        "Ben Hill County",
        "Berrien County",
        "Bibb County",
        "Bleckley County",
        "Brantley County",
        "Brooks County",
        "Bryan County",
        "Bulloch County",
        "Burke County",
        "Butts County",
        "Calhoun County",
        "Camden County",
        "Candler County",
        "Carroll County",
        "Catoosa County",
        "Charlton County",
        "Chatham County",
        "Chattahoochee",
        "Chattooga",
        "Cherokee County",
        "Clarke County",
        "Clay County",
        "Clayton County",
        "Clinch County",
        "Cobb County",
        "Coffee County",
        "Colquitt County",
        "Columbia County",
        "Cook County",
        "Coweta County",
        "Crawford County",
        "Crisp County",
        "Dade County",
        "Dawson County",
        "Decatur County",
        "Dekalb County",
        "Dodge County",
        "Dooly County",
        "Dougherty County",
        "Douglas County",
        "Early County",
        "Echols County",
        "Effingham County",
        "Elbert County",
        "Emanuel County",
        "Evans County",
        "Fannin County",
        "Fayette County",
        "Floyd County",
        "Forsyth County",
        "Franklin County",
        "Fulton County",
        "Gilmer County",
        "Glascock County",
        "Glynn County",
        "Gordon County",
        "Grady County",
        "Greene County",
        "Gwinnett County",
        "Habersham County",
        "Hall County",
        "Hancock County",
        "Haralson County",
        "Harris County",
        "Hart County",
        "Heard County",
        "Henry County",
        "Houston County",
        "Irwin County",
        "Jackson County",
        "Jasper County",
        "Jeff Davis",
        "Jefferson County",
        "Jenkins County",
        "Johnson County",
        "Jones County",
        "Lamar County",
        "Lanier County",
        "Laurens County",
        "Lee County",
        "Liberty County",
        "Lincoln County",
        "Long County",
        "Lowndes County",
        "Lumpkin County",
        "Macon County",
        "Madison County",
        "Marion County",
        "McDuffie County",
        "Mcintosh County",
        "Meriwether County",
        "Miller County",
        "Mitchell County",
        "Monroe County",
        "Montgomery County",
        "Morgan County",
        "Murray County",
        "Muscogee",
        "Newton County",
        "Oconee County",
        "Oglethorpe County",
        "Paulding County",
        "Peach County",
        "Pickens County",
        "Pierce County",
        "Pike County",
        "Polk County",
        "Pulaski County",
        "Putnam County",
        "Quitman County",
        "Rabun County",
        "Randolph County",
        "Richmond County",
        "Rockdale County",
        "Schley County",
        "Screven County",
        "Seminole County",
        "Spalding County",
        "Stephens County",
        "Stewart County",
        "Sumter County",
        "Talbot County",
        "Taliaferro County",
        "Tattnall County",
        "Taylor County",
        "Telfair County",
        "Terrell County",
        "Thomas County",
        "Tift County",
        "Toombs County",
        "Towns County",
        "Treutlen County",
        "Troup County",
        "Turner County",
        "Twiggs County",
        "Union County",
        "Upson County",
        "Walker County",
        "Walton County",
        "Ware County",
        "Warren County",
        "Washington County",
        "Wayne County",
        "Webster County",
        "Wheeler County",
        "White County",
        "Whitfield County",
        "Wilcox County",
        "Wilkes County",
        "Wilkinson County",
        "Worth County",
      ]}},	
      {"abr_check_mailing_address": {type: :checkbox}},	
      {"abr_mailing_address_line_1": {required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_city": {required: :if_visible, visible: "abr_check_mailing_address", classes: "half"}},	
      {"abr_mailing_state_name": {type: :select, required: :if_visible, visible: "abr_check_mailing_address", classes: "quarter", options: GeoState.collection_for_select}},
      {"abr_mailing_zip": {required: :if_visible, visible: "abr_check_mailing_address", classes: "quarter"}},
      {"abr_id_type": {type: :radio, required: :true}},
      {"abr_drivers_license": {required: :if_visible, visible: "abr_id_type_abr_id_type1", regexp: /\A\d{9}\z/}},	
      {"abr_id_instructions": {type: :instructions, visible: "abr_id_type_abr_id_type2"}},
      {"abr_election_type_selections_options": {type: :radio, required: true}},
      {"abr_primary_type_selections1": {type: :radio, required: :if_visible, visible_any: "abr_election_type_selections_options_abr_election_type1 abr_election_type_selections_options_abr_election_type3"}},
      {"abr_assistant_check1": {type: :checkbox}},
      {"abr_assistant_instructions": {type: :instructions, visible: "abr_assistant_check1"}},
      {"abr_assistant_name": {visible: "abr_assistant_check1", required: :if_visible}},
      {"abr_request_instructions": {type: :instructions}},	
      {"abr_request_check": {type: :checkbox}},	
      {"abr_request_selections": {type: :radio, visible: "abr_request_check"}},
      {"abr_relationship1": {required: :if_visible, visible: "abr_request_check"}},
      {"abr_application_type_check1": {type: :checkbox}},	
      {"abr_application_type_selections":  {type: :radio, required: :if_visible, visible: "abr_application_type_check1"}},	
    ]
  end
  
  
  # def custom_form_field_validations
  #   if self.has_mailing_address.to_s == "1"
  #     MAIL_FIELDS.each do |f|
  #       custom_validates_presence_of(f)
  #      end
  #   end
  #   if self.requestor.to_s == "1"
  #     custom_validates_presence_of("Relationship to voter")
  #     custom_validates_presence_of("Group2")
  #   end
  #   if self.assisted_voter.to_s == "1"
  #     custom_validates_presence_of("Name of assistant")
  #   end
  #   if self.Elegibility == "U"
  #     custom_validates_presence_of("Group3")
  #   end
  # end


end