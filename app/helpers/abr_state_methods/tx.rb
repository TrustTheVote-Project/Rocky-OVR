module AbrStateMethods::TX
  
  PDF_FIELDS = {
     "drivers_license": {},
     "last_4_ssn": {},
     "no_id": {}, #options: ["Off", "Yes"]
     "delivery_address": {
       options: [
        "residence_address",
        "other_address",
       ]
     },
     "abr_mailing_street_address": { pdf_field: "mailing_street_address"},
     "abr_mailing_unit": {pdf_field: "mailing_unit"},
     "abr_mailing_city": {pdf_field: "mailing_city"},
     "abr_mailing_state_name": {pdf_field: "mailing_state_name"},
     "abr_mailing_zip": {pdf_field: "mailing_zip"},

     "address_type_selections": {
       options: [
        "address_type1",
        "address_type2",
        "address_type3",
        "address_type4",        
       ]
     },
     "relationship1": {},
     "relationship2": {},
     "reason_selections": {
        options: [
          "reason1",
          "reason2",
          "reason3",
          "reason4",
          "reason5",
        ]
     },
     "absence_begin_date_mm": {},
     "absence_begin_date_dd": {},
     "absence_begin_date_yyyy": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "where_to_mail_all", "absence_begin_date"]
  
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
      {"id_instructions": {type: :instructions }},
      {"drivers_license": {}},
      {"last_4_ssn": {}},
      {"no_id": {type: :checkbox}},
      {"delivery_address": {type: :radio}},
      {"abr_mailing_street_address": {visible: "delivery_address_other_address", required: :if_visible}},
      {"abr_mailing_unit": {visible: "delivery_address_other_address"}},
      {"abr_mailing_city": {visible: "delivery_address_other_address", required: :if_visible}},
      {"abr_mailing_state_name": {visible: "delivery_address_other_address", required: :if_visible}},
      {"abr_mailing_zip": {visible: "delivery_address_other_address", required: :if_visible}},

      {"address_type_selections": {type: :radio, visible: "delivery_address_other_address", required: :if_visible}},
      {"relationship1": {visible: "address_type_selections_address_type3", required: :if_visible}},
      {"relationship2": {visible: "address_type_selections_address_type4", required: :if_visible}},
      {"reason_selections": {type: :radio, required: true}},
      {"absence_begin_date": {visible: "reason_selections_reason4", type: :date}},

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