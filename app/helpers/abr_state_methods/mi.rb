module AbrStateMethods::MI

  # PDF MAPPING
  PDF_FIELDS = {
    "abr_email":  { method: "email" },
    "abr_phone":  { method: "phone" },
    "abr_first_name":  { method: "first_name" },
    "abr_middle_initial": { method: "middle_initial" },
    "abr_last_name":  { method: "last_name" },
    "abr_name_suffix": { method: "name_suffix" },

    # single full street line
    "abr_street_name": { method: "street" },

    "abr_city":  { method: "city" },
    "abr_home_state_abbrev": { method: "home_state_abbrev" },
    "abr_zip":   { method: "zip" },
    #"abr_full_name": { method: "full_name" },
    "abr_date_of_birth_yyyy": { method: "date_of_birth_yyyy" },

    "abr_check_mailing_address": { options: %w[Off On] },
    "abr_absence_begin_date": { method: "absence_begin_date_string" },
    "abr_absence_end_date":   { method: "absence_end_date_string" },
    "abr_mailing_address_line_1": {},
    "abr_mailing_city": {},
    "abr_mailing_state_abbrev": {},
    "abr_mailing_zip": {},

    "abr_county": {},
    "abr_city_checkbox":     { options: ["Yes"] },
    "abr_township_checkbox": { options: ["Yes"] },
    "abr_jurisdiction": {},

    "abr_election_type_selections_1": { options: %w[Off Yes] },
    "abr_election_type_selections_2": { options: %w[Off Yes] },
    "abr_election_type_selections_3": { options: %w[Off Yes] },

    "abr_permanent_list_opt_in": { options: %w[Off Yes] },
    "abr_request_check": { options: %w[Off On] },
    "abr_request_name": {method: "abr_request_name"},
    "assist_birthdate": { method: "assist_birthdate_date_string" },
    "abr_assistant_address_line_1": {},
    "abr_assistant_deliver_for": { method: "assistant_deliver_for" }
  }

  EXTRA_FIELDS = [
    "assist_birthdate_date_input","assist_birthdate_date_input_mm",
    "assist_birthdate_date_input_dd","assist_birthdate_date_input_yyyy",
    "abr_absence_begin_date_input","abr_absence_begin_date_input_mm",
    "abr_absence_begin_date_input_dd","abr_absence_begin_date_input_yyyy",
    "abr_absence_end_date_input","abr_absence_end_date_input_mm",
    "abr_absence_end_date_input_dd","abr_absence_end_date_input_yyyy",
    "abr_election_type_selections_1","abr_election_type_selections_2",
    "abr_election_type_selections_3","abr_assistant_deliver_for",
    "abr_mailing_address_line_1"
  ]

  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Alcona", "Alger", "Allegan", "Alpena", "Antrim", "Arenac", "Baraga", "Barry",
        "Bay", "Benzie", "Berrien", "Branch", "Calhoun", "Cass", "Charlevoix", "Cheboygan",
        "Chippewa", "Clare", "Clinton", "Crawford", "Delta", "Dickinson", "Eaton", "Emmet",
        "Genesee", "Gladwin", "Gogebic", "Grand Traverse", "Gratiot", "Hillsdale", "Houghton",
        "Huron", "Ingham", "Ionia", "Iosco", "Iron", "Isabella", "Jackson", "Kalamazoo",
        "Kalkaska", "Kent", "Keweenaw", "Lake", "Lapeer", "Leelanau", "Lenawee", "Livingston",
        "Luce", "Mackinac", "Macomb", "Manistee", "Marquette", "Mason", "Mecosta", "Menominee",
        "Midland", "Missaukee", "Monroe", "Montcalm", "Montmorency", "Muskegon", "Newaygo",
        "Oakland", "Oceana", "Ogemaw", "Ontonagon", "Osceola", "Oscoda", "Otsego", "Ottawa",
        "Presque Isle", "Roscommon", "Saginaw", "St. Clair", "St. Joseph", "Sanilac",
        "Schoolcraft", "Shiawassee", "Tuscola", "Van Buren", "Washtenaw", "Wayne", "Wexford"
      ]}},
      {"abr_address_type_selections": { type: :radio, options: ["abr_city_checkbox", "abr_township_checkbox"], required: true }},
      {"abr_jurisdiction": { required: true }},
      {"abr_check_mailing_address": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_absence_begin_date_input": {type: :date , required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_absence_end_date_input": {type: :date, required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_address_line_1": {required: :if_visible, visible: "abr_check_mailing_address"}},
      #{"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},
      {"abr_election_type_selections": {type: :instructions}},
      {"abr_election_type_selections_1": { type: :checkbox}},
      {"abr_election_type_selections_2": { type: :checkbox}},
      {"abr_election_type_selections_3": { type: :checkbox}},
      {"abr_permanent_list_opt_in": { type: :checkbox}},
      {"abr_request_check": {type: :checkbox, options: ["Off", "On"]}},
      {"abr_request_name": { required: :if_visible, visible: "abr_request_check"}},
      {"assist_birthdate_date_input": {type: :date, required: :if_visible, visible: "abr_request_check"}},
      {"abr_assistant_address_line_1": {required: :if_visible, visible: "abr_request_check"}}
    ]
  end

  def custom_form_field_validations
    if truthy?(abr_request_check) && !test_date(assist_birthdate_date_string.to_s)
      errors.add("assist_birthdate_date_input", custom_format_message("bad_date"))
    end
    if truthy?(abr_check_mailing_address) && !test_date(absence_begin_date_string.to_s)
      errors.add("abr_absence_begin_date_input", custom_format_message("bad_date"))
    end
    if truthy?(abr_check_mailing_address) && !test_date(absence_end_date_string.to_s)
      errors.add("abr_absence_end_date_input", custom_format_message("bad_date"))
    end
  end

  def street
    number = street_number.to_s.strip
    name   = street_name.to_s.strip
    unit   = formatted_unit(self[:unit])

    [number, name, unit].reject(&:empty?).join(" ")
  end

  def assist_birthdate_date_string
    date_field_string_mm_dd_yy_l(method: :assist_birthdate_date_input)
  end

  def absence_begin_date_string
    date_field_string_mm_dd_yy_l(method: :abr_absence_begin_date_input)
  end

  def absence_end_date_string
    date_field_string_mm_dd_yy_l(method: :abr_absence_end_date_input)
  end

  def assistant_deliver_for
    return "" unless truthy?(abr_request_check)
    [first_name.to_s.strip, last_name.to_s.strip].reject(&:empty?).join(" ")
  end

  def date_field_string_mm_dd_yy_l(field_opts)
    d = date_field_value(field_opts)
    d&.strftime("%m  %d  %y")
  rescue
    nil
  end

  def date_field_string_mm_dd_yy(field_opts)
    d = date_field_value(field_opts)
    d&.strftime("%m %d %y")
  rescue
    nil
  end

  def abr_address_type_selections
    return "abr_city_checkbox" if abr_city_checkbox == "Yes"
    return "abr_township_checkbox" if abr_township_checkbox == "Yes"
    nil
  end

  def abr_address_type_selections=(value)
    self.abr_city_checkbox = (value == "abr_city_checkbox") ? "Yes" : "Off"
    self.abr_township_checkbox = (value == "abr_township_checkbox") ? "Yes" : "Off"
  end

  def abr_election_type_selections
    nil
  end

  def abr_election_type_selections_1
    self[:abr_election_type_selections_1] == "1" ? "Yes" : "Off"
  end

  def abr_election_type_selections_2
    self[:abr_election_type_selections_2] == "1" ? "Yes" : "Off"
  end

  def abr_election_type_selections_3
    self[:abr_election_type_selections_3] == "1" ? "Yes" : "Off"
  end

  def truthy?(val)
    %w[1 yes on true].include?(val.to_s.strip.downcase)
  end

  def test_date(datestring)
    Date.strptime(datestring, "%m %d  %y")
    true
  rescue ArgumentError
    false
  end

  DESCRIPTORS = %w[
    apt apartment ste suite unit floor fl bldg building
    rm room dept department ofc office lot box
  ].freeze

  # ↓ note: we allow an optional trailing period (e.g., "Apt." or "Rm.")
  DESCRIPTOR_REGEX = /\A(?:#{DESCRIPTORS.join("|")})\.?\b/i

  def formatted_unit(unit_string)
    raw = unit_string.to_s.strip
    return "" if raw.blank?
    raw = raw.sub(/^#\s*/, "") # strip a leading "#"
    raw.match?(DESCRIPTOR_REGEX) ? raw : "##{raw}"
  end

end