module AbrStateMethods::TX
  
  PDF_FIELDS = {
     "abr_drivers_license": { sensitive: true },
     "abr_no_drivers_license": {options: ["Off", "Yes"]},
     "abr_last_4_ssn": { sensitve: true },
     "abr_no_id": {options: ["Off", "Yes"]},
     "abr_delivery_address": {
       options: [
         "abr_residence_address",
         "abr_mailing_address",
         "abr_other_address"
       ]
     },  # Web-only field for first-tier selection
     "abr_mail_address_type_selections": {
       options: [
         "abr_mail_address_type1",
         "abr_mail_address_type2"
       ]
     },
     "abr_mailing_street_address": { },
     "abr_mailing_unit": {},
     "abr_mailing_city": {},
     "abr_mailing_state_name": {},
     "abr_mailing_zip": {},

     "abr_address_type_selections": {
       options: [
        "abr_address_type1",
        "abr_address_type2",
        "abr_address_type3",
       ]
     },
     "abr_relationship1": {},
     "abr_relationship2": {},
     "abr_reason_selections": {
        options: [
          "abr_reason1",
          "abr_reason2",
          "abr_reason3",
          "abr_reason4",
          "abr_reason5",
        ]
     },
     "abr_absence_begin_date_mm": {},
     "abr_absence_begin_date_dd": {},
     "abr_absence_begin_date_yyyy": {},
     "abr_absence_end_date_mm": {},
     "abr_absence_end_date_dd": {},
     "abr_absence_end_date_yyyy": {},

     "abr_application_type1": {options: ["Off", "Yes"], method: :yes_if_abr_reason1_or_abr_reason2 },

     "abr_primary_type_selections1": {
       options: [
         "abr_primary_type1",
         "abr_primary_type2",
         "abr_primary_type3"
       ]
     },
     "abr_primary_runoff_dem1": {},
     "abr_primary_runoff_rep1": {},
     "abr_primary_type_selections1b": {
       options: [
         "abr_primary_type1",
         "abr_primary_type2"
       ]
     },
     "abr_primary_type_selections2": {
       options: [
         "abr_primary_type4",
         "abr_primary_type5"
       ]
     },
     "abr_primary_runoff_dem2": {},
     "abr_primary_runoff_rep2": {},
     "abr_primary_type_selections2b": {
       options: [
         "abr_primary_type1",
         "abr_primary_type2"
       ]
     },
     "abr_election_selection": {
       options: [
        "abr_election_selection_type1",
        "abr_election_selection_type2",
        "abr_election_selection_type3",
        "abr_election_selection_type4"
       ]
     },
     "abr_election_selection_type1": {options: ["Off", "Yes"]},
     "abr_election_selection_type2": {options: ["Off", "Yes"]},
     "abr_election_selection_type3": {options: ["Off", "Yes"]},
     "abr_election_selection_type4": {options: ["Off", "Yes"]},
     "abr_march_primary_selection": {},  # Web-only field, doesn't map to PDF


      "abr_has_assistant": {options: ["Off", "Yes"]},
      "abr_assistant_check1": {options: ["Off", "Yes"]},
      "abr_witness_info1": {},
      "abr_witness_check1": {options: ["Off", "Yes"]},
      "abr_witness_full_name": {},
      "abr_assistant_address_line_1": {},
      "abr_assistant_unit": {},
      "abr_assistant_city": {},
      "abr_assistant_state_name": {},
      "abr_assistant_zip": {},
      "abr_assistant_check2": {options: ["Off", "Yes"]},

      # Mapped PDF fields
      "abr_email": {method: "email"},
      "abr_last_name": {method: "last_name"},
      "abr_first_name": {method: "first_name"},
      "abr_middle_name": {method: "middle_name"},
      "abr_name_suffix": {method: "name_suffix"},
      "abr_date_of_birth_mm": {method: "date_of_birth_mm"},
      "abr_date_of_birth_dd": {method: "date_of_birth_dd"},
      "abr_date_of_birth_yyyy": {method: "date_of_birth_yyyy"},
      "abr_street_name": {method: "address_line_1"},
      "abr_unit": {method: "unit"},
      "abr_city": {method: "city"},
      "abr_home_state_name": {value: "TX"},
      "abr_zip": {method: "zip"},
      "abr_phone": {method: "phone"},

      # Envelope "From" fields
      "From whom: Name": {method: :envelope_from_name},
      "From whom: Addresss": {method: :envelope_from_address},
      "From whom: city, state, zip code": {method: :envelope_from_city_state_zip},

      # Voting clerk address fields
      "VotingClerkAddress": {method: :voting_clerk_address},
      "VotingClerkCityStateZipCode": {method: :voting_clerk_city_state_zip},
  }

  EXTRA_FIELDS = ["abr_absence_begin_date", "abr_absence_end_date", "abr_delivery_address", "abr_address_type_selections", "abr_primary_runoff_dem1", "abr_primary_runoff_rep1", "abr_primary_runoff_dem2", "abr_primary_runoff_rep2"]
  
  # def yes_if_no_mailing_address
  #   if self.has_mailing_address == "0"
  #     return "Yes"
  #   else
  #     return "Off"
  #   end
  # end

  # def yes_if_has_mailing_address
  #   if self.has_mailing_address == "1"
  #     return "Yes"
  #   else
  #     return "Off"
  #   end
  # end

  # def november_election_if_over_65
  #   if self.send(self.class.make_method_name("Reason")) == "age" || self.send(self.class.make_method_name("Reason")) == "disability"
  #     "November_election" 
  #   else
  #     "Off"
  #   end
  # end
  
  # def november_election_if_confined_to_jail
  #   if self.send(self.class.make_method_name("Reason")) == "confinement" || self.send(self.class.make_method_name("Reason")) == "absence" 
  #     "November_election" 
  #   else
  #     "Off"
  #   end
  # end

  # def any_resulting_runoff_if_over_65
  #   if self.send(self.class.make_method_name("Reason")) == "age" || self.send(self.class.make_method_name("Reason")) == "disability"
  #     "Yes" 
  #   else
  #     "Off"
  #   end
  # end
  
  # def any_resulting_runoff_if_confined_to_jail
  #   if self.send(self.class.make_method_name("Reason")) == "confinement" || self.send(self.class.make_method_name("Reason")) == "absence" || self.send(self.class.make_method_name("Reason")) == "maternity"
  #     "Yes" 
  #   else
  #     "Off"
  #   end
  # end
  
  def yes_if_abr_reason1_or_abr_reason2
    if self.abr_reason_selections == "abr_reason1" || self.abr_reason_selections == "abr_reason2"
      "Yes"
    else
      "Off"
    end
  end

  # Custom date of birth methods with spacing between digits for TX PDF form
  def date_of_birth_mm
    super&.chars&.join(' ')
  end

  def date_of_birth_dd
    super&.chars&.join(' ')
  end

  def date_of_birth_yyyy
    super&.chars&.join(' ')
  end

  # Map runoff checkboxes to PDF radio button group for reasons 1 & 2
  def abr_primary_type_selections1b
    if self.abr_primary_runoff_dem1 == "1"
      "abr_primary_type1"
    elsif self.abr_primary_runoff_rep1 == "1"
      "abr_primary_type2"
    else
      nil
    end
  end

  # Map runoff checkboxes to PDF radio button group for reasons 3, 4, 5
  def abr_primary_type_selections2b
    if self.abr_primary_runoff_dem2 == "1"
      "abr_primary_type1"
    elsif self.abr_primary_runoff_rep2 == "1"
      "abr_primary_type2"
    else
      nil
    end
  end

  # Helper methods for conditional visibility of primary type selections
  def abr_primary_type_selections1_abr_primary_type1
    abr_primary_type_selections1 == "abr_primary_type1" ? "1" : "0"
  end

  def abr_primary_type_selections1_abr_primary_type2
    abr_primary_type_selections1 == "abr_primary_type2" ? "1" : "0"
  end

  def abr_primary_type_selections2_abr_primary_type4
    abr_primary_type_selections2 == "abr_primary_type4" ? "1" : "0"
  end

  def abr_primary_type_selections2_abr_primary_type5
    abr_primary_type_selections2 == "abr_primary_type5" ? "1" : "0"
  end


  def form_field_items
    [
      {"abr_reason_selections": {type: :radio, required: true}},
      {"abr_absence_begin_date": {visible: "abr_reason_selections_abr_reason4", type: :date, required: :if_visible}},
      {"abr_absence_end_date": {visible: "abr_reason_selections_abr_reason4", type: :date, required: :if_visible}},
      #{"abr_id_instructions": {type: :instructions }},
      {"abr_drivers_license": {required: :if_visible, hidden: "abr_no_drivers_license", regexp: /\A\d{8}\z/}},
      {"abr_no_drivers_license": {type: :checkbox}},
      {"abr_last_4_ssn": {required: :if_visible, visible: "abr_no_drivers_license", hidden: "abr_no_id", regexp: /\A\d{4}\z/}},
      {"abr_no_id": {type: :checkbox, visible: "abr_no_drivers_license"}},

      {"abr_delivery_address": {type: :radio, required: true}},

      {"abr_mailing_street_address": {classes: "three-quarter", visible: "abr_delivery_address_abr_other_address", required: :if_visible}},
      {"abr_mailing_unit": {classes: "quarter", visible: "abr_delivery_address_abr_other_address"}},
      {"abr_mailing_city": {classes: "half", visible: "abr_delivery_address_abr_other_address", required: :if_visible}},
      {"abr_mailing_state_name": {classes: "quarter", visible: "abr_delivery_address_abr_other_address", required: :if_visible, type: :select, options: GeoState.collection_for_select}},

      {"abr_mailing_zip": {classes: "quarter", visible: "abr_delivery_address_abr_other_address", required: :if_visible}},

      {"abr_address_type_selections": {type: :radio, visible: "abr_delivery_address_abr_other_address", required: :if_visible}},

      {"abr_relationship1": {visible: "abr_address_type_selections_abr_address_type1"}},
      {"abr_relationship2": {visible: "abr_address_type_selections_abr_address_type2"}},
      
      # {"abr_application_type1_instructions_header": {type: :instructions}},
      # {"abr_application_type1_instructions": {type: :instructions, visible: "abr_reason_selections_abr_reason1 abr_reason_selections_abr_reason2"}},

      #{"abr_application_type1": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason1 abr_reason_selections_abr_reason2"}},

      {"abr_primary_type_selections1": {type: :radio, visible_any: "abr_reason_selections_abr_reason1 abr_reason_selections_abr_reason2", required: :if_visible}},
      {"abr_primary_runoff_dem1": {type: :checkbox, visible: "abr_primary_type_selections1_abr_primary_type1"}},
      {"abr_primary_runoff_rep1": {type: :checkbox, visible: "abr_primary_type_selections1_abr_primary_type2"}},

      {"abr_election_header": {type: :instructions, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},
      {"abr_election_selection_type1": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},
      {"abr_election_selection_type2": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},
      {"abr_election_selection_type3": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},
      {"abr_election_selection_type4": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},
      {"abr_march_primary_selection": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason3 abr_reason_selections_abr_reason4 abr_reason_selections_abr_reason5"}},

      {"abr_primary_type_selections2": {type: :radio, visible: "abr_march_primary_selection", required: :if_visible}},
      {"abr_primary_runoff_dem2": {type: :checkbox, visible: "abr_primary_type_selections2_abr_primary_type4"}},
      {"abr_primary_runoff_rep2": {type: :checkbox, visible: "abr_primary_type_selections2_abr_primary_type5"}},

      #{"abr_assistant_instructions": {type: :instructions}},
      # {"abr_assistant_information": {type: :instructions}},
      #{"abr_has_assistant": {type: :checkbox}},
      {"abr_assistant_check1": {type: :checkbox, visible: "abr_has_assistant"}},
      {"abr_witness_check1": {type: :checkbox, visible: "abr_has_assistant"}},
      {"abr_witness_info1": {visible: "abr_witness_check1", required: :if_visible}},
      {"abr_assistant_check2": {type: :checkbox, visible: "abr_has_assistant"}},
      {"abr_witness_full_name": {visible: "abr_has_assistant", required: :if_visible }},
      {"abr_assistant_address_line_1": {classes: "three-quarter",visible: "abr_has_assistant", required: :if_visible}},
      {"abr_assistant_unit": {classes: "quarter",visible: "abr_has_assistant"}},
      {"abr_assistant_city": {classes: "half",visible: "abr_has_assistant", required: :if_visible}},
      {"abr_assistant_state_name": {classes: "quarter",visible: "abr_has_assistant", required: :if_visible,  type: :select, options: GeoState.collection_for_select}},
      {"abr_assistant_zip": {classes: "quarter",visible: "abr_has_assistant", required: :if_visible}},
      
      # {"Reason": {required: true, type: :radio}}, 
      # {"absent_from": {classes: 'half', visible: "reason_absence", type: :date, d: "absence_from_dd", m: "absence_from_mm", y: "absence_from_yyyy" }},
      # {"absent_to": {classes: 'half last', visible: "reason_absence", type: :date, d: "absence_to_dd", m: "absence_to_mm", y: "absencs_to_yyyy" }},
      # {"has_mailing_address": {type: :checkbox}},
      # {"Address_2": {visible: "has_mailing_address", classes: "three-quarter"}},
      # {"Apt if any 2": {visible: "has_mailing_address", classes: "quarter last"}},
      # {"City 2": {visible: "has_mailing_address", classes: "half"}},
      # {"State 2": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      # {"Zip Code 2": {visible: "has_mailing_address", classes: "quarter last", min: 5, max: 10}},
      # {"where_to_mail_all": {
      #   required: :if_visible,
      #   visible: "has_mailing_address", type: :radio, options: ["mailing_address", "outside_county", "relative", "hospital", "jail"]}}, 
      # {"relative_relationship": {visible: "where_to_mail_all_relative"}},
      # {"witness": {
      #   type: :checkbox}}, 
      # {"Assisted": {
      #   visible: "witness", 
      #   type: :checkbox}},
      # {"Witness_relation": {
      #   visible: "witness"}},
      #   #witness' relationship to applicant
      # {"Street address of witness": {
      #   classes: "three-quarter",
      #   visible: "witness"}}, 
      # {"Apt number of witness": {
      #   classes: "quarter last",
      #   visible: "witness"}}, 
      # {"City of witness": {
      #   classes: "half",
      #   visible: "witness"}},
      # {"State of witness": {
      #   classes: "quarter",
      #   visible: "witness",
      #   type: :select, options: GeoState.collection_for_select, include_blank: true}}, 
      # {"Zip code of witness": {
      #   classes: "quarter last",
      #   visible: "witness"}},
    ]
  end
  

  def custom_form_field_validations
    if self.abr_has_assistant == "1"
      if self.abr_witness_check1 != "1" && self.abr_assistant_check1 != "1" && self.abr_assistant_check2 != "1"
        t = I18n.t('states.custom.tx.abr_form_errors.must_select_one_witness_type')
        errors.add(:abr_witness_check1, t)
        errors.add(:abr_assistant_check1, t)
        errors.add(:abr_assistant_check2, t)
      end
    end

    if self.abr_no_id != "1" && self.abr_drivers_license.blank? && self.abr_last_4_ssn.blank?
      t = I18n.t('states.custom.tx.abr_form_errors.id_required')
      errors.add(:abr_drivers_license, t)
      errors.add(:abr_last_4_ssn, t)
    end

    # Require at least one election selection for reasons 3, 4, or 5
    if ["abr_reason3", "abr_reason4", "abr_reason5"].include?(self.abr_reason_selections)
      if self.abr_election_selection_type1 != "1" && self.abr_election_selection_type2 != "1" &&
         self.abr_election_selection_type3 != "1" && self.abr_election_selection_type4 != "1" &&
         self.abr_march_primary_selection != "1"
        t = I18n.t('states.custom.tx.abr_form_errors.must_select_one_election')
        errors.add(:abr_election_selection_type1, t)
      end
    end
    
    abr_absence_begin_date = begin
      self.date_field_value(method: :abr_absence_begin_date)
    rescue
      nil
    end
    abr_absence_end_date = begin
      self.date_field_value(method: :abr_absence_end_date)
    rescue
      nil
    end
    
    if abr_absence_end_date && abr_absence_end_date < Date.today
      errors.add(:abr_absence_end_date, I18n.t('states.custom.tx.abr_form_errors.absence_end_date_after_today'))
    end
    if abr_absence_begin_date && abr_absence_end_date && abr_absence_end_date < abr_absence_begin_date
      errors.add(:abr_absence_end_date, I18n.t('states.custom.tx.abr_form_errors.absence_end_date_after_begin_date'))
    end
  end

  # Helper methods for conditional visibility based on delivery address selection
  def abr_delivery_address_abr_residence_address
    abr_delivery_address == "abr_residence_address" ? "1" : "0"
  end

  def abr_delivery_address_abr_mailing_address
    abr_delivery_address == "abr_mailing_address" ? "1" : "0"
  end

  def abr_delivery_address_abr_other_address
    abr_delivery_address == "abr_other_address" ? "1" : "0"
  end

  # Map delivery address selection to mail address type for PDF
  def abr_mail_address_type_selections
    case self.abr_delivery_address
    when "abr_residence_address"
      "abr_mail_address_type1"
    when "abr_mailing_address"
      "abr_mail_address_type2"
    else
      nil
    end
  end

  # Map "other address" selection to address type for PDF
  def abr_address_type_selections
    if self.abr_delivery_address == "abr_other_address"
      # Return the user's selected sub-option (type1, type2, or type3)
      read_attribute(:abr_address_type_selections)
    else
      nil
    end
  end

  # Helper methods for conditional visibility of relationship fields
  def abr_address_type_selections_abr_address_type1
    abr_address_type_selections == "abr_address_type1" ? "1" : "0"
  end

  def abr_address_type_selections_abr_address_type2
    abr_address_type_selections == "abr_address_type2" ? "1" : "0"
  end

  def abr_address_type_selections_abr_address_type3
    abr_address_type_selections == "abr_address_type3" ? "1" : "0"
  end

  # Envelope "From" field methods
  def envelope_from_name
    [first_name, middle_name, last_name, name_suffix].compact.join(" ")
  end

  def envelope_from_address
    [address_line_1, unit].compact.join(" ")
  end

  def envelope_from_city_state_zip
    [city, home_state_abbrev, zip].compact.join(", ")
  end

  def voting_clerk_address
    county_address = ZipCodeCountyAddress.find_by_zip(self.zip)
    return "" unless county_address
    # Street address only (office name removed to prevent cutoff)
    [county_address.req_street1, county_address.req_street2].compact.reject(&:blank?).join(" ")
  end

  def voting_clerk_city_state_zip
    county_address = ZipCodeCountyAddress.find_by_zip(self.zip)
    return "" unless county_address
    [county_address.req_city, county_address.req_state, county_address.req_zip].compact.reject(&:blank?).join(", ")
  end

  # def where_to_mail_consolidated
  #   val = self.send(self.class.make_method_name("where_to_mail_all")) 
  #   if val == "relative"
  #     return "hospital"
  #   end
  #   return val
  # end

  # def custom_form_field_validations
  #   if self.has_mailing_address.to_s == "1"
  #     ["Address 2", "City 2", "State 2", "Zip Code 2"].each do |f|
  #       custom_validates_presence_of(f)
  #       #errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
  #     end
  #   end
  #   if self.reason == "absence" && self.has_mailing_address != "1"
  #     errors.add(:has_mailing_address, "You must provide a mailing address outside of your residece county")
  #   end
  #   if self.reason == "confinement" && self.has_mailing_address != "1"
  #     errors.add(:has_mailing_address, "You must provide a mailing address")
  #   end
    
  #   if self.send(self.class.make_method_name("where_to_mail_all")) == "relative"
  #     custom_validates_presence_of("relative_relationship")
  #   end
  #   if self.send("witness") == "1"
  #     ["Witness_relation",
  #     "Street address of witness",
  #     "City of witness",
  #     "State of witness",
  #     "Zip code of witness"].each do |f|
  #       custom_validates_presence_of(f)
  #     end
  #   end
  # end

  
end