module AbrStateMethods::TX
  
  PDF_FIELDS = {
     "abr_drivers_license": { sensitive: true },
     "abr_last_4_ssn": { sensitve: true },
     "abr_no_id": {options: ["Off", "Yes"]},
     "abr_delivery_address": {
       options: [
        "abr_residence_address",
        "abr_mailing_address",
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
        "abr_address_type4",        
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

     "abr_application_type1": {options: ["Off", "Yes"]},

     "abr_primary_type_selections1": {
       options: [
         "abr_primary_type1",
         "abr_primary_type2",
         "abr_primary_type3"
       ]
     },
     "abr_election_type_selections": {
       options: [
        "abr_election_type1",
        "abr_election_type2",
       ]
     },
     "abr_election_type1_selections": {
       options: [
          "abr_election_type1_subtype1",
          "abr_election_type1_subtype2",
          "abr_election_type1_subtype3",
          "abr_election_type1_subtype4",
       ]
      },
      "abr_primary_type_selections2": {
        options: [
          "abr_primary_type4",
          "abr_runoff_type3",
          "abr_primary_type5",
          "abr_runoff_type5",  
        ]
      },
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
  }

  EXTRA_FIELDS = ["abr_absence_begin_date"]
  
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
  
  
  
  
  def form_field_items
    [
      {"abr_id_instructions": {type: :instructions }},
      {"abr_drivers_license": {required: false, regexp: /\A\d{8}\z/}},
      {"abr_last_4_ssn": {required: false, regexp: /\A\d{4}\z/}},
      {"abr_no_id": {type: :checkbox, required: false,}},
      {"abr_delivery_address": {type: :radio}},
      {"abr_mailing_street_address": {visible: "abr_delivery_address_abr_mailing_address", required: :if_visible}},
      {"abr_mailing_unit": {visible: "abr_delivery_address_abr_mailing_address"}},
      {"abr_mailing_city": {visible: "abr_delivery_address_abr_mailing_address", required: :if_visible}},
      {"abr_mailing_state_name": {visible: "abr_delivery_address_abr_mailing_address", type: :select, options: GeoState.collection_for_select}},
      
      {"abr_mailing_zip": {visible: "abr_delivery_address_abr_mailing_address", required: :if_visible}},

      {"abr_address_type_selections": {type: :radio, visible: "abr_delivery_address_abr_mailing_address", required: :if_visible}},
      {"abr_relationship1": {visible: "abr_address_type_selections_abr_address_type3", required: :if_visible}},
      {"abr_relationship2": {visible: "abr_address_type_selections_abr_address_type4", required: :if_visible}},
      {"abr_reason_selections": {type: :radio, required: true}},
      {"abr_absence_begin_date": {visible: "abr_reason_selections_abr_reason4", type: :date, required: :if_visible}},
      {"abr_absence_end_date": {visible: "abr_reason_selections_abr_reason4", type: :date, required: :if_visible}},

      {"abr_application_type1_instructions_header": {type: :instructions}},
      {"abr_application_type1_instructions": {type: :instructions, visible: "abr_reason_selections_abr_reason1 abr_reason_selections_abr_reason2"}},

      {"abr_application_type1": {type: :checkbox, visible_any: "abr_reason_selections_abr_reason1 abr_reason_selections_abr_reason2"}},

      {"abr_primary_type_selections1": {type: :radio, visible: "abr_application_type1", required: :if_visible}},

      
      {"abr_election_type_selections": {type: :radio, hidden: "abr_application_type1", required: :if_visible}},
      
      {"abr_election_type1_selections": {type: :radio, visible: "abr_election_type_selections_abr_election_type1", required: :if_visible}},
      {"abr_primary_type_selections2": {type: :radio, visible: "abr_election_type_selections_abr_election_type2", required: :if_visible}},

      {"abr_has_assistant": {type: :checkbox}},

      {"abr_witness_check1": {type: :checkbox, visible: "abr_has_assistant"}},
      {"abr_witness_info1": {visible: "abr_witness_check1", required: :if_visible}},
      {"abr_assistant_check1": {type: :checkbox, visible: "abr_has_assistant"}},
      {"abr_witness_full_name": {visible: "abr_has_assistant", required: :if_visible }},
      {"abr_assistant_address_line_1": {visible: "abr_has_assistant", required: :if_visible}},
      {"abr_assistant_unit": {visible: "abr_has_assistant"}},
      {"abr_assistant_city": {visible: "abr_has_assistant", required: :if_visible}},
      {"abr_assistant_state_name": {visible: "abr_has_assistant", required: :if_visible,  type: :select, options: GeoState.collection_for_select}},
      {"abr_assistant_zip": {visible: "abr_has_assistant", required: :if_visible}},
      {"abr_assistant_check2": {type: :checkbox, visible: "abr_has_assistant"}},

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