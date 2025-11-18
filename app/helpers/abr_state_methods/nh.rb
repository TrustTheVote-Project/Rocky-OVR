module AbrStateMethods::NH
  def self.included(base)
    base.validate :validate_party_selection_for_primary
  end

  # --------------------------
  # PDF FIELD MAPPINGS
  # --------------------------
  PDF_FIELDS = {
    # Name parts
    "abr_first_name":  { method: "first_name" },
    "abr_middle_name": { method: "middle_name" },
    "abr_last_name":   { method: "last_name" },
    "abr_name_suffix": { method: "name_suffix" },

    # Residential address
    "abr_street_number": { method: "street_number" },
    "abr_street_name":   { method: "street_name" },
    "abr_unit":          { method: "unit" },
    "abr_city":          { method: "city" },
    "abr_ward":          { method: "abr_ward" },
    "abr_zip":           { method: "zip" },

    # Mailing address
    "abr_mailing_street_number": { method: "abr_mailing_street_number" },
    "abr_mailing_street_name":   { method: "abr_mailing_street_name" },
    "abr_mailing_unit":          { method: "abr_mailing_unit" },
    "abr_mailing_city":          { method: "abr_mailing_city" },
    "abr_mailing_ward":          { method: "abr_mailing_ward" },
    "abr_mailing_zip":           { method: "abr_mailing_zip" },

    # Phone (split)
    "abr_phone":  { method: "phone_area" },
    "abr_phone2": { method: "phone_prefix" },
    "abr_phone3": { method: "phone_suffix" },

    # Email (split local@domain)
    "abr_email":  { method: "abr_email"  },
    "abr_email2": { method: "abr_email2" },

    # Application + reason radios
    "abr_application_type_selections": { options: %w[abr_application_type1 abr_application_type2] },
    "abr_reason_selections_for_pdf": {
      pdf_name: "abr_reason_selections",  # Actual PDF field name
      method: "abr_reason_for_pdf"  # Method that returns the correct value
    },
    "abr_reason_6_selections": { options: %w[abr_reason6_type1 abr_reason6_type2] },

    # Party selection - PDF field mapping
    # NOTE: This is the actual PDF field. We map it from a custom method that consolidates
    # two UI fields (abr_party_selections and abr_party_selections2 from form_field_items)
    "abr_party_selection_for_pdf_field": {
      pdf_name: "abr_party_selections",  # Actual PDF field name
      method: "abr_party_selection_for_pdf"  # Method that returns the selected party
    },

    # Election type PDF field - uses custom method to return mapped value (1→3, 2→4)
    "abr_election_type_for_pdf_field": {
      pdf_name: "abr_election_type_selections",  # Actual PDF field name
      method: "abr_election_type_for_pdf"         # Returns mapped value
    },

    # Debug field (prints raw -> mapped)
    # "Printed name of notarial officer": { method: "nh_pdf_debug_election" },

    # Election dates (formatted as m/d/yy)
    "abr_election_date":  { method: "abr_election_date_string" },
    "abr_election_date2": { method: "abr_election_date2_string" },

    # ID checkboxes - each maps to whether that option is selected
    "abr_id_type1": { method: "abr_id_type1_checked" },
    "abr_id_type2": { method: "abr_id_type2_checked" },
    "abr_id_type3": { method: "abr_id_type3_checked" },

    # Assistance
    "abr_assistant_check1": {},
    "abr_assistant_name":   {}
  }

  # --------------------------
  # UI-only fields (not literal PDF acrofields)
  # --------------------------
  EXTRA_FIELDS = %w[
    abr_application_type_selections
    abr_reason_selections
    abr_reason_6_selections
    abr_ward
    abr_check_mailing_address
    abr_mailing_street_number
    abr_mailing_street_name
    abr_mailing_unit
    abr_mailing_city
    abr_mailing_ward
    abr_mailing_zip
    abr_id_selections
    abr_election_type_selections
    abr_election_type_for_pdf_field
    abr_election_date_input_mm
    abr_election_date_input_dd
    abr_election_date_input_yyyy
    abr_election_date2_input_mm
    abr_election_date2_input_dd
    abr_election_date2_input_yyyy
    abr_party_selections
    abr_party_selections2
  ]

  # --------------------------
  # FORM ITEMS (unchanged UI)
  # --------------------------
  def form_field_items
    [
      { "abr_application_type_selections": { type: :radio, options: %w[abr_application_type1 abr_application_type2], required: true } },
      { "abr_reason_selections": { type: :radio, options: %w[abr_reason1 abr_reason2 abr_reason3 abr_reason4 abr_reason5 abr_reason6], required: true } },
      { "abr_reason_6_selections": { type: :radio, options: %w[abr_reason6_type1 abr_reason6_type2], visible: "abr_reason_selections_abr_reason6", required: :if_visible } },
      { "abr_election_type_selections": { type: :radio, options: %w[abr_election_type1 abr_election_type2 abr_election_type3 abr_election_type4], required: true } },
      { "abr_election_date_input": { type: :date, visible: "abr_election_type_selections_abr_election_type3", required: :if_visible } },
      { "abr_election_date2_input": { type: :date, visible: "abr_election_type_selections_abr_election_type4", required: :if_visible } },
      { "abr_party_selections": { type: :radio, options: %w[abr_party1 abr_party2 abr_party_none], visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type_selections_abr_election_type3", required: :if_visible, hint_key: "abr_party_selections__hint" } },
      { "abr_party_selections2": { type: :radio, options: %w[abr_party3 abr_party4 abr_party_none2], visible_any: "abr_election_type_selections_abr_election_type1 abr_election_type_selections_abr_election_type3", required: :if_visible, hint_key: "abr_party_selections2__hint" } },
      { "abr_ward": {} },
      { "abr_check_mailing_address": { type: :checkbox } },
      { "abr_mailing_street_number": { classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_street_name":   { classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_unit":          { classes: 'quarter', required: false, visible: "abr_check_mailing_address" } },
      { "abr_mailing_city":          { classes: 'half', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_ward":          { classes: 'half', required: false, visible: "abr_check_mailing_address" } },
      { "abr_mailing_zip":           { classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_ward_instructions": { type: :instructions, visible: "abr_check_mailing_address" } },
      { "abr_id_selections": { type: :radio, options: %w[abr_id_type1 abr_id_type2 abr_id_type3], required: true, hint_key: "abr_id_selections__hint" } },
      { "abr_assistant_check1": { type: :checkbox } },
      { "abr_assistant_name":   { visible: "abr_assistant_check1", required: :if_visible } }
    ]
  end

  # ==========================================================
  # ELECTION TYPE MAPPING (single source of truth)
  # - Store the RAW UI token whenever we see either param
  # - Compute mapped token for PDF: 1→3, 2→4, pass-through 3/4
  # ==========================================================

  # Absorb legacy/hidden field and funnel through the canonical setter
  def abr_election_type_for_pdf=(v)
    @abr_election_type_raw = v.to_s
    # also drive the canonical UI setter, in case the rest of the code reads it
    self.abr_election_type_selections = v
  end

  # Canonical UI setter (preferred field)
  def abr_election_type_selections=(v)
    raw = v.to_s.strip
    return if raw.empty?

    @abr_election_type_raw = raw
    @abr_election_type_mapped = map_election_token(raw)

    # Persist raw value to database
    state_val = self.abr_state_values.find_or_initialize_by(attribute_name: 'abr_election_type_selections')
    state_val.string_value = raw
    unless state_val.new_record?
      self.association(:abr_state_values).add_to_target(state_val)
    end
  end

  # Canonical UI getter - returns RAW value for form pre-selection
  def abr_election_type_selections
    # Load raw value from DB if not in memory
    if @abr_election_type_raw.nil? || @abr_election_type_raw.empty?
      db_value = self.abr_state_values.find_by(attribute_name: 'abr_election_type_selections')&.string_value
      @abr_election_type_raw = db_value if db_value
    end
    @abr_election_type_raw.to_s
  end

  # PDF getter - returns MAPPED value for PDF radio selection (1→3, 2→4)
  def abr_election_type_for_pdf
    raw_value = abr_election_type_selections  # Get raw value
    map_election_token(raw_value)              # Return mapped value
  end

  # Debug helper shown in the PDF for verification
  def nh_pdf_debug_election
    raw    = abr_election_type_selections.to_s    # Raw value from form
    mapped = abr_election_type_for_pdf.to_s       # Mapped value for PDF
    "UI=#{raw} -> PDF=#{mapped}"
  end

  # Pure mapping logic
  def map_election_token(raw)
    case raw.to_s
    when "abr_election_type1", "abr_election_type3" then "abr_election_type3"
    when "abr_election_type2", "abr_election_type4" then "abr_election_type4"
    else "abr_election_type3" # safe default to ensure a radio is selected
    end
  end

  # --------------------------
  # EMAIL (split)
  # --------------------------
  def full_email_source
    if respond_to?(:email) && !email.to_s.strip.empty?
      email.to_s.strip
    else
      @abr_email.to_s.strip
    end
  end
  def abr_email  ; full_email_source.split('@', 2)[0] || "" end
  def abr_email=(val); @abr_email = val; end
  def abr_email2 ; full_email_source.split('@', 2)[1] || "" end
  def abr_email2=(val); @abr_email2 = val; end

  # --------------------------
  # DATE FIELDS (formatted as m/d/yy for PDF)
  # --------------------------

  # Primary election date (type1 or type3)
  # - type1: Hardcoded to September 8, 2026 (9/8/26)
  # - type3: User enters date manually
  def abr_election_date_string
    # Check election type
    election_type = abr_election_type_selections

    # Type1 = State Primary Election on September 8, 2026
    if election_type == "abr_election_type1"
      return "9/8/26"
    end

    # Type3 = Special Primary (user enters date)
    if election_type == "abr_election_type3"
      mm_dd_yyyy = date_field_string_mm_dd_yyyy(method: :abr_election_date_input)
      return "" if mm_dd_yyyy.blank?

      # Convert mm/dd/yyyy to m/d/yy format
      if mm_dd_yyyy =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})$}
        month = $1.to_i
        day = $2.to_i
        year = $3.to_i % 100  # Get last 2 digits of year
        return "#{month}/#{day}/#{year}"
      end

      return mm_dd_yyyy
    end

    ""
  end

  # General election date (type2 or type4)
  # - type2: Hardcoded to November 3, 2026 (11/3/26)
  # - type4: User enters date manually
  def abr_election_date2_string
    # Check election type
    election_type = abr_election_type_selections

    # Type2 = General Election on November 3, 2026
    if election_type == "abr_election_type2"
      return "11/3/26"
    end

    # Type4 = Special General (user enters date)
    if election_type == "abr_election_type4"
      mm_dd_yyyy = date_field_string_mm_dd_yyyy(method: :abr_election_date2_input)
      return "" if mm_dd_yyyy.blank?

      # Convert mm/dd/yyyy to m/d/yy format
      if mm_dd_yyyy =~ %r{^(\d{1,2})/(\d{1,2})/(\d{4})$}
        month = $1.to_i
        day = $2.to_i
        year = $3.to_i % 100  # Get last 2 digits of year
        return "#{month}/#{day}/#{year}"
      end

      return mm_dd_yyyy
    end

    ""
  end

  # --------------------------
  # PHONE (split)
  # --------------------------
  def phone_area
    return @phone_area if @phone_area.to_s.strip != ""
    respond_to?(:phone) && phone.to_s =~ /(\d{3})\D*(\d{3})\D*(\d{4})/ ? $1 : ""
  end
  def phone_area=(v); @phone_area = v; end

  def phone_prefix
    return @phone_prefix if @phone_prefix.to_s.strip != ""
    respond_to?(:phone) && phone.to_s =~ /(\d{3})\D*(\d{3})\D*(\d{4})/ ? $2 : ""
  end
  def phone_prefix=(v); @phone_prefix = v; end

  def phone_suffix
    return @phone_suffix if @phone_suffix.to_s.strip != ""
    respond_to?(:phone) && phone.to_s =~ /(\d{3})\D*(\d{3})\D*(\d{4})/ ? $3 : ""
  end
  def phone_suffix=(v); @phone_suffix = v; end

  # --------------------------
  # VISIBILITY helpers
  # --------------------------
  def abr_reason_selections_abr_reason6
    abr_reason_selections.to_s == 'abr_reason6'
  end

  # Show party selection only for primary elections (type1 or type3)
  def abr_election_type_primary
    election_type = abr_election_type_selections.to_s
    election_type == 'abr_election_type1' || election_type == 'abr_election_type3'
  end

  # Detect if party group 1 (party1/party2) has a selection
  def abr_party_selections_selected
    abr_party_selections.to_s =~ /^abr_party[12]$/
  end

  # Detect if party group 2 (party3/party4) has a selection
  def abr_party_selections2_selected
    abr_party_selections2.to_s =~ /^abr_party[34]$/
  end

  # Return the selected party for PDF (from either UI group)
  # Maps two UI fields to single PDF field
  def abr_party_selection_for_pdf
    # Check group 1 (registered voters)
    if abr_party_selections.to_s =~ /^abr_party[12]$/
      return abr_party_selections
    end
    # Check group 2 (undeclared voters)
    if abr_party_selections2.to_s =~ /^abr_party[34]$/
      return abr_party_selections2
    end
    # Return empty if "none" selected or nothing selected
    ""
  end

  # --------------------------
  # REASON SELECTION MAPPING
  # --------------------------
  # When reason6 (inclement weather) is selected, use the sub-selection instead
  # This prevents abr_reason6 from being selected on PDF; instead abr_reason6_type1 or abr_reason6_type2 is selected

  def abr_reason_for_pdf
    # If reason6 is selected, return the sub-selection (type1 or type2)
    if abr_reason_selections == "abr_reason6"
      return abr_reason_6_selections.to_s
    end
    # Otherwise return the main reason selection
    return abr_reason_selections.to_s
  end

  # --------------------------
  # ID TYPE CHECKBOX METHODS
  # --------------------------
  # Map radio selection to individual PDF checkboxes

  def abr_id_type1_checked
    abr_id_selections == "abr_id_type1" ? "On" : "Off"
  end

  def abr_id_type2_checked
    abr_id_selections == "abr_id_type2" ? "On" : "Off"
  end

  def abr_id_type3_checked
    abr_id_selections == "abr_id_type3" ? "On" : "Off"
  end

  # --------------------------
  # CUSTOM VALIDATIONS
  # --------------------------

  # Validate party selection for primary elections
  # - Exactly ONE party must be selected from EITHER group 1 OR group 2
  # - "None" options don't count as valid selections
  def validate_party_selection_for_primary
    return unless abr_election_type_primary  # Only validate for primary elections

    group1_selected = abr_party_selections.to_s =~ /^abr_party[12]$/
    group2_selected = abr_party_selections2.to_s =~ /^abr_party[34]$/

    # Require exactly one party selected from exactly one group
    if !group1_selected && !group2_selected
      errors.add(:abr_party_selections, I18n.t('states.custom.nh.custom_errors.party_selection_required'))
      errors.add(:abr_party_selections2, I18n.t('states.custom.nh.custom_errors.party_selection_required'))
    elsif group1_selected && group2_selected
      errors.add(:abr_party_selections, I18n.t('states.custom.nh.custom_errors.party_selection_only_one_group'))
      errors.add(:abr_party_selections2, I18n.t('states.custom.nh.custom_errors.party_selection_only_one_group'))
    end
  end

  # --------------------------
  # HELPER METHODS FOR VISIBILITY
  # --------------------------

  # Helper methods for visibility conditions
  # These check if specific radio options are selected
  def abr_election_type_selections_abr_election_type3
    abr_election_type_selections == "abr_election_type3"
  end

  def abr_election_type_selections_abr_election_type4
    abr_election_type_selections == "abr_election_type4"
  end

  # --------------------------
  # ATTR ACCESSORS (misc)
  # --------------------------
  attr_accessor :abr_application_type_selections,
                :abr_reason_selections,
                :abr_reason_6_selections,
                :select_election_type_selections,
                :abr_ward,
                :abr_check_mailing_address,
                :abr_mailing_street_number,
                :abr_mailing_street_name,
                :abr_mailing_unit,
                :abr_mailing_city,
                :abr_mailing_ward,
                :abr_mailing_zip,
                :abr_id_selections,
                :abr_party_selections,
                :abr_party_selections2
end