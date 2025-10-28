module AbrStateMethods::NH
  PDF_FIELDS = {
    "abr_first_name":         { method: "first_name" },
    "abr_middle_name":        { method: "middle_name" },
    "abr_last_name":          { method: "last_name" },
    "abr_name_suffix":        { method: "name_suffix" },

    "abr_street_number":      { method: "street_number" },
    "abr_street_name":        { method: "street_name" },
    "abr_unit":               { method: "unit" },
    "abr_city":               { method: "city" },
    "abr_ward":               { method: "abr_ward" },
    "abr_zip":                { method: "zip" },

    "abr_mailing_street_number": { method: "abr_mailing_street_number" },
    "abr_mailing_street_name":   { method: "abr_mailing_street_name" },
    "abr_mailing_unit":          { method: "abr_mailing_unit" },
    "abr_mailing_city":          { method: "abr_mailing_city" },
    "abr_mailing_ward":          { method: "abr_mailing_ward" },
    "abr_mailing_zip":           { method: "abr_mailing_zip" },

    "abr_phone":      { method: "phone_area" },
    "abr_phone2":     { method: "phone_prefix" },
    "abr_phone3":     { method: "phone_suffix" },

    "abr_email":      { method: "abr_email" },
    "abr_email2":     { method: "abr_email2" },

    "abr_application_type_selections": {
      options: ['abr_application_type1', 'abr_application_type2']
    },

    "abr_reason_selections": {
      options: [
        'abr_reason1','abr_reason2','abr_reason3',
        'abr_reason4','abr_reason5','abr_reason6'
      ]
    },

    "abr_reason_6_selections": {
      options: ['abr_reason6_type1','abr_reason6_type2']
    },

    "abr_election_type3": { method: "select_election_type3?" },
    "abr_election_type4": { method: "select_election_type4?" },

    "abr_election_date":  { method: "election_date_string" },
    "abr_election_date2": { method: "election_date2_string" },

    "abr_party_selections": { method: "nh_party_export_value" },

    "abr_id_type1": {},
    "abr_id_type2": {},
    "abr_id_type3": {},

    "abr_assistant_check1": {},
    "abr_assistant_name":   {}
  }

  EXTRA_FIELDS = [
    "abr_election_date_input_dd",
    "abr_election_date_input_mm",
    "abr_election_date_input_yyyy",
    "abr_election_date2_input_dd",
    "abr_election_date2_input_mm",
    "abr_election_date2_input_yyyy",

    "abr_application_type_selections",
    "abr_reason_selections",
    "abr_reason_6_selections",

    "abr_election_type_selections",
    "nh_pdf_election_choice",
    "nh_pdf_election_choice_for_pdf",

    "abr_party_selections",
    "abr_party_selections2",
    "nh_party_export_value",

    "abr_election_date_input",
    "abr_election_date2_input",

    "abr_ward",
    "abr_check_mailing_address",
    "abr_mailing_street_number",
    "abr_mailing_street_name",
    "abr_mailing_unit",
    "abr_mailing_city",
    "abr_mailing_ward",
    "abr_mailing_zip",

    "abr_id_selections",
    "abr_assistant_check1",
    "abr_assistant_name"
  ]

  def form_field_items
    [
      { "abr_application_type_selections": { type: :radio, options: ['abr_application_type1','abr_application_type2'], required: true } },

      { "abr_reason_selections": { type: :radio, options: ['abr_reason1','abr_reason2','abr_reason3','abr_reason4','abr_reason5','abr_reason6'], required: true } },
      { "abr_reason_6_selections": { type: :radio, options: ['abr_reason6_type1','abr_reason6_type2'], visible: "abr_reason_selections_abr_reason6", required: :if_visible } },

      { "nh_pdf_election_choice_for_pdf": { type: :radio, options: ['abr_election_type1','abr_election_type2','abr_election_type3','abr_election_type4'], required: true } },

      { "abr_party_selections":  { type: :radio, options: ['abr_party1','abr_party2'], visible: "nh_pdf_election_choice_for_pdf_abr_election_type1", required: :if_visible } },
      { "abr_party_selections2": { type: :radio, options: ['abr_party3','abr_party4'], visible: "nh_pdf_election_choice_for_pdf_abr_election_type3", required: :if_visible } },

      { "abr_election_date_input":  { type: :date, visible: "nh_pdf_election_choice_for_pdf_abr_election_type3", required: :if_visible } },
      { "abr_election_date2_input": { type: :date, visible: "nh_pdf_election_choice_for_pdf_abr_election_type4", required: :if_visible } },

      { "abr_ward": {} },

      { "abr_check_mailing_address": { type: :checkbox } },
      { "abr_mailing_street_number": { classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_street_name":   { classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_unit":          { classes: 'quarter', required: false, visible: "abr_check_mailing_address" } },
      { "abr_mailing_city":          { classes: 'half', required: :if_visible, visible: "abr_check_mailing_address" } },
      { "abr_mailing_ward":          { classes: 'half', required: :if_visible, visible: "abr_check_mailing_address", hint_key: "abr_mailing_ward__hint" } },
      { "abr_mailing_zip":           { classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address" } },

      { "abr_id_selections": { type: :radio, options: ['abr_id_type1','abr_id_type2','abr_id_type3'], required: true, hint_key: "abr_id_selections__hint" } },

      { "abr_assistant_check1": { type: :checkbox } },
      { "abr_assistant_name":   { visible: "abr_assistant_check1", required: :if_visible } }
    ]
  end

  def build_date(mm, dd, yyyy)
    mm_s = mm.to_s.strip
    dd_s = dd.to_s.strip
    yy_s = yyyy.to_s.strip
    mm_s = mm_s.rjust(2, '0') unless mm_s.empty?
    dd_s = dd_s.rjust(2, '0') unless dd_s.empty?
    yy_s = yy_s[-2, 2] unless yy_s.empty?
    [mm_s, dd_s, yy_s].reject(&:empty?).join('/')
  end

  def pdf_election_type_for_radio
    case abr_election_type_selections_normalized
    when "abr_election_type1" then "abr_election_type3"
    when "abr_election_type2" then "abr_election_type4"
    when "abr_election_type3" then "abr_election_type3"
    when "abr_election_type4" then "abr_election_type4"
    else ""
    end
  end

  def select_election_type3?
    pdf_election_type_for_radio == "abr_election_type3"
  end

  def select_election_type4?
    pdf_election_type_for_radio == "abr_election_type4"
  end

  def election_date_string
    case abr_election_type_selections_normalized
    when 'abr_election_type1' then "09/08/26"
    when 'abr_election_type3'
      build_date(abr_election_date_input_mm, abr_election_date_input_dd, abr_election_date_input_yyyy)
    else ""
    end
  end

  def election_date2_string
    case abr_election_type_selections_normalized
    when 'abr_election_type2' then "11/03/26"
    when 'abr_election_type4'
      build_date(abr_election_date2_input_mm, abr_election_date2_input_dd, abr_election_date2_input_yyyy)
    else ""
    end
  end

  def full_email_source
    if respond_to?(:email) && !email.to_s.strip.empty?
      email.to_s.strip
    else
      @abr_email.to_s.strip
    end
  end
  def abr_email; full_email_source.split('@', 2)[0] || "" end
  def abr_email=(val); @abr_email = val; end
  def abr_email2; full_email_source.split('@', 2)[1] || "" end
  def abr_email2=(val); @abr_email2 = val; end

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

  def nh_party_export_value
    case abr_election_type_selections_normalized
    when "abr_election_type1"
      v = abr_party_selections.to_s.strip
      %w[abr_party1 abr_party2].include?(v) ? v : ""
    when "abr_election_type3"
      v = abr_party_selections2.to_s.strip
      %w[abr_party3 abr_party4].include?(v) ? v : ""
    else ""
    end
  end

  def nh_party_export_value=(val)
    v = val.to_s.strip
    @nh_party_export_value = v
    
    if %w[abr_party1 abr_party2].include?(v)
      @abr_party_selections = v
    elsif %w[abr_party3 abr_party4].include?(v)
      @abr_party_selections2 = v
    end
  end

  def custom_form_field_validations
    # Check if a primary type was selected and party choice is missing
    if %w[abr_election_type1 abr_election_type3].include?(abr_election_type_selections_normalized)
      has_party = !abr_party_selections.to_s.strip.empty? || 
                  !abr_party_selections2.to_s.strip.empty? || 
                  !@nh_party_export_value.to_s.strip.empty?
      
      unless has_party
        errors.add(:nh_party_export_value, "You must choose a party ballot for a primary.")
      end
    end

    if abr_check_mailing_address.to_s == '1'
      %i[abr_mailing_street_number abr_mailing_street_name abr_mailing_city abr_mailing_ward abr_mailing_zip].each do |fld|
        errors.add(fld, "This field is required for your mailing address.") if send(fld).to_s.strip.empty?
      end
    end
  end

  def abr_application_type_selections; @abr_application_type_selections; end
  def abr_application_type_selections=(v); @abr_application_type_selections = v; end

  def abr_reason_selections; @abr_reason_selections; end
  def abr_reason_selections=(v); @abr_reason_selections = v; end

  def abr_reason_6_selections; @abr_reason_6_selections; end
  def abr_reason_6_selections=(v); @abr_reason_6_selections = v; end

  def nh_pdf_election_choice_for_pdf; @nh_pdf_election_choice_for_pdf; end
  def nh_pdf_election_choice_for_pdf=(v)
    @nh_pdf_election_choice_for_pdf = v
    @abr_election_type_selections = v if v.present?
    @nh_pdf_election_choice = v if v.present?
  end

  def abr_election_type_selections; @abr_election_type_selections; end
  def abr_election_type_selections=(v)
    @abr_election_type_selections = v
    @nh_pdf_election_choice_for_pdf = v if v.present?
    @nh_pdf_election_choice = v if v.present?
  end

  def nh_pdf_election_choice; @nh_pdf_election_choice; end
  def nh_pdf_election_choice=(v)
    @nh_pdf_election_choice = v
    @abr_election_type_selections = v if v.present?
    @nh_pdf_election_choice_for_pdf = v if v.present?
  end

  def abr_party_selections; @abr_party_selections; end
  def abr_party_selections=(v); @abr_party_selections = v; end
  def abr_party_selections2; @abr_party_selections2; end
  def abr_party_selections2=(v); @abr_party_selections2 = v; end

  def abr_election_date_input; @abr_election_date_input; end
  def abr_election_date_input=(v); @abr_election_date_input = v; end
  def abr_election_date2_input; @abr_election_date2_input; end
  def abr_election_date2_input=(v); @abr_election_date2_input = v; end

  def abr_election_date_input_dd; @abr_election_date_input_dd; end
  def abr_election_date_input_dd=(v); @abr_election_date_input_dd = v; end
  def abr_election_date_input_mm; @abr_election_date_input_mm; end
  def abr_election_date_input_mm=(v); @abr_election_date_input_mm = v; end
  def abr_election_date_input_yyyy; @abr_election_date_input_yyyy; end
  def abr_election_date_input_yyyy=(v); @abr_election_date_input_yyyy = v; end

  def abr_election_date2_input_dd; @abr_election_date2_input_dd; end
  def abr_election_date2_input_dd=(v); @abr_election_date2_input_dd = v; end
  def abr_election_date2_input_mm; @abr_election_date2_input_mm; end
  def abr_election_date2_input_mm=(v); @abr_election_date2_input_mm = v; end
  def abr_election_date2_input_yyyy; @abr_election_date2_input_yyyy; end
  def abr_election_date2_input_yyyy=(v); @abr_election_date2_input_yyyy = v; end

  def abr_ward; @abr_ward; end
  def abr_ward=(v); @abr_ward = v; end

  def abr_check_mailing_address; @abr_check_mailing_address; end
  def abr_check_mailing_address=(v); @abr_check_mailing_address = v; end

  def abr_mailing_street_number; @abr_mailing_street_number; end
  def abr_mailing_street_number=(v); @abr_mailing_street_number = v; end
  def abr_mailing_street_name; @abr_mailing_street_name; end
  def abr_mailing_street_name=(v); @abr_mailing_street_name = v; end
  def abr_mailing_unit; @abr_mailing_unit; end
  def abr_mailing_unit=(v); @abr_mailing_unit = v; end
  def abr_mailing_city; @abr_mailing_city; end
  def abr_mailing_city=(v); @abr_mailing_city = v; end
  def abr_mailing_ward; @abr_mailing_ward; end
  def abr_mailing_ward=(v); @abr_mailing_ward = v; end
  def abr_mailing_zip; @abr_mailing_zip; end
  def abr_mailing_zip=(v); @abr_mailing_zip = v; end

  def abr_id_selections; @abr_id_selections; end
  def abr_id_selections=(v); @abr_id_selections = v; end

  def abr_assistant_check1; @abr_assistant_check1; end
  def abr_assistant_check1=(v); @abr_assistant_check1 = v; end
  def abr_assistant_name; @abr_assistant_name; end
  def abr_assistant_name=(v); @abr_assistant_name = v; end

  def abr_reason_selections_abr_reason6
    abr_reason_selections.to_s == 'abr_reason6'
  end
  
  def nh_pdf_election_choice_for_pdf_abr_election_type1
    abr_election_type_selections_normalized == 'abr_election_type1'
  end
  
  def nh_pdf_election_choice_for_pdf_abr_election_type3
    abr_election_type_selections_normalized == 'abr_election_type3'
  end
  
  def nh_pdf_election_choice_for_pdf_abr_election_type4
    abr_election_type_selections_normalized == 'abr_election_type4'
  end
  
  def abr_election_type_selections_normalized
    (@abr_election_type_selections || @nh_pdf_election_choice || @nh_pdf_election_choice_for_pdf).to_s
  end
  
  def nh_pdf_primary?
    %w[abr_election_type1 abr_election_type3].include?(abr_election_type_selections_normalized)
  end
  
  def nh_pdf_general?
    %w[abr_election_type2 abr_election_type4].include?(abr_election_type_selections_normalized)
  end

  def pdf_party_selection_for_radio=(val)
    @ignored_pdf_party = val.to_s
  end
end