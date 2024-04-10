module AbrStateMethods::NE
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_name": {method: "middle_name"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "date_of_birth_mm_dd_yyyy": {method: "date_of_birth_mm_dd_yyyy"},

    "abr_street_name": {method: "street_name"},
    "abr_street_number": {method: "street_number"},
    "abr_unit": {method: "unit"},
    "abr_city": {method: "city"},
    "abr_home_state_abbrev": {method: "home_state_abbrev"},
    "abr_zip": {method: "zip"},

	"abr_id_selections":{
      options:[
        'abr_id_type1',
        'abr_id_type2',
        'abr_id_type3',
      ]
    },
    "abr_drivers_license": {sensitive:true},

    "abr_primary_type_selections1": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3",
        "abr_primary_type4",
      ]
    },

    "abr_address_type1": {
      method: "abr_address_type1_value",
      options: ["Off", "On"]
    },	
    "abr_check_mailing_address": {},	
    "abr_mailing_address_line_1": {},
    "abr_mailing_unit": {},	
    "abr_mailing_city":{},   
    "abr_mailing_state_abbrev": {},
    "abr_mailing_zip": {},

    "abr_phone": { method: "phone"},	
  }
  EXTRA_FIELDS = ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip", {name:"abr_drivers_license", sensitive:true}]
  
  def mailing_address_city_state_zip
    ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip"].collect {|f| 
      self.send(f) || nil
    }.compact.join(" ")
  end
  
  def abr_address_type1_value
    if self.abr_check_mailing_address.to_s == "1"
      return "Off"
    else
      return "On"
    end
  end

  def form_field_items
    [
      {"abr_id_selections": {type: :radio, required: true, options: ["abr_id_type1", "abr_id_type2", "abr_id_type3"]}},
      {"abr_drivers_license": {visible: "abr_id_selections_abr_id_type1", required: :if_visible, ui_regexp:"^[a-zA-Z][0-9]{8}$|^[0-9]{9}$", min:9, max:9}},
      {"abr_primary_type_selections1": {required: false, type: :radio}},
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_line_1": {classes: "three-quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_unit": {classes: "quarter", visible: "abr_check_mailing_address"}},
      {"abr_mailing_city": {classes: "half",  required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_state_abbrev": {classes: "quarter",  required: :if_visible, visible: "abr_check_mailing_address", type: :select, options: GeoState.collection_for_select}},
      {"abr_mailing_zip": {classes: "quarter",  required: :if_visible, visible: "abr_check_mailing_address"}},
    ]
  end  
  
  def custom_form_field_validations
  end
  
  def election_date_string
    date_field_string_mm_dd_yyyy(method: :election_date)
  end

 
end