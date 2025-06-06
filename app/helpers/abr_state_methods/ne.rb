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

    "abr_id_selections": {
      options: [
        'abr_id_type1',
        'abr_id_type2',
        'abr_id_type3',
      ]
    },
    "abr_drivers_license": {sensitive: true},

    "abr_election_type_selections": {
      options: ["abr_election_type1", "abr_election_type2"],
      method: "abr_election_type_selections"
    },
    "abr_election_date": {
      method: "abr_special_election_date_string"
    },

    "abr_address_type1": {
      method: "abr_address_type1_value",
      options: ["Off", "On"]
    },	
    "abr_check_mailing_address": {},	
    "abr_mailing_address_line_1": {},
    "abr_mailing_unit": {},
    "abr_mailing_city": {},   
    "abr_mailing_state_abbrev": {},
    "abr_mailing_zip": {},

    "abr_phone": {method: "phone"},
  }

  EXTRA_FIELDS = ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip", "abr_special_election_date_mm", "abr_special_election_date_dd", "abr_special_election_date_yyyy", {name: "abr_drivers_license", sensitive: true}]

  def mailing_address_city_state_zip
    ["abr_mailing_address_city", "abr_mailing_address_state", "abr_mailing_address_zip"].collect do |f| 
      self.send(f) || nil
    end.compact.join(" ")
  end

  def abr_address_type1_value
    self.abr_check_mailing_address.to_s == "1" ? "Off" : "On"
  end

  def form_field_items
    [
      {"abr_id_instructions": {type: :instructions}},
      {"abr_id_selections": {type: :radio, required: true, options: ["abr_id_type1", "abr_id_type2", "abr_id_type3"]}},
      {"abr_drivers_license": {
        visible: "abr_id_selections_abr_id_type1",
        required: :if_visible,
        ui_regexp: "^[a-zA-Z][0-9]{8}$|^[0-9]{9}$",
        min: 9,
        max: 9
      }},
      {"abr_election_type_selections": {
        type: :radio,
        required: true,
        options: ["abr_election_type1", "abr_election_type2"]
      }},
      {"abr_special_election_date": {
        type: :date,
        visible: "abr_election_type_selections_abr_election_type2",
        required: :if_visible
      }},
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_line_1": {classes: "three-quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_unit": {classes: "quarter", visible: "abr_check_mailing_address"}},
      {"abr_mailing_city": {classes: "half", required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_state_abbrev": {
        classes: "quarter",
        required: :if_visible,
        visible: "abr_check_mailing_address",
        type: :select,
        options: GeoState.collection_for_select
      }},
      {"abr_mailing_zip": {classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
    ]
  end

  def custom_form_field_validations
    if abr_election_type_selections.blank?
      errors.add(:abr_election_type_selections, custom_required_message('abr_no_election_checked'))
    elsif abr_election_type_selections == "abr_election_type2" && abr_special_election_date.blank?
      errors.add(:abr_special_election_date, custom_required_message('abr_special_election_date_required'))
    end
  end

  def abr_special_election_date_string
    date_field_string_mm_dd_yyyy(method: :abr_special_election_date)
  end

  def abr_special_election_date_string_mm
    abr_special_election_date_mm
  end

  def abr_special_election_date_string_dd
    abr_special_election_date_dd
  end

  def abr_special_election_date_string_yyyy
    abr_special_election_date_yyyy
  end

  def abr_special_election_date_string_mm=(value)
    self.abr_special_election_date_mm = value
  end

  def abr_special_election_date_string_dd=(value)
    self.abr_special_election_date_dd = value
  end

  def abr_special_election_date_string_yyyy=(value)
    self.abr_special_election_date_yyyy = value
  end

  def abr_special_election_date
    [abr_special_election_date_mm, abr_special_election_date_dd, abr_special_election_date_yyyy].join('-').presence
  end

end