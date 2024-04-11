module AbrStateMethods::AR
  
  PDF_FIELDS = {
    "undefined": { method: "delivery_addressee" },
    "TO COUNTY CLERK 1": {method: "delivery_street1" },
    "TO COUNTY CLERK 2": {method: "delivery_city_state_zip" },
    
    "abr_email": { method: "email" },
    "abr_reason_instructions": {},
    "abr_full_name": { method: "full_name" },
    "date_of_birth": {
      pdf_name: "date_of_birth_mm_dd_yyyy",
      method: "date_of_birth_mm_dd_yyyy" 
    },
    "abr_address_line_1": { method: "address_line_1" },
    "abr_address_city_state_zip": { method: "address_city_state_zip" },
    "abr_address_type_selections": {
      options: [
        "abr_address_type1",
        "abr_address_type2"
      ]
    },
    "abr_delivery_address_selections": {
      options: [
        "abr_delivery_address_type1",
        "abr_delivery_address_type2",
        "abr_delivery_address_type3",
      ]
    },
    "abr_check_mailing_address": { options: ["Off", "Yes"] },
    "abr_mailing_address_line_1": { method: "mailing_addr_1" },
    "abr_mailing_address_city_state_zip": { method: "mailing_addr_2" },
    "Mail Please send my ballot to the following address 3": { method: "mailing_addr_3" }, 
    "abr_request_name": { },

    "abr_reason_selections": {
      options: [
        "abr_reason1",
        "abr_reason2",
        "abr_reason3",
        "abr_reason4"
      ]
    },

    "abr_election_type1": { options: ["Off", "Yes"] },
    "abr_election_type_selections": {
      options: [
        "abr_election_type2",
        "abr_election_type3",
        "abr_election_type4",
        "abr_election_type5",
      ]
    },
    "abr_election_date": {method: "abr_election_date_string"},

    "abr_assistant_check_selections": {
      options: [
        "abr_assistant_check_option1",
        "abr_assistant_check_option2",
      ]
    },
    "abr_assistant_name": {},
    "abr_assistant_address_line1": {},
    "abr_assistant_city": {},
    "abr_assistant_state_abbrev": {},
    "abr_assistant_zip": {},


    "abr_phone": {method: "phone"},
  }

  EXTRA_FIELDS = [
    "abr_election_date_input_mm", "abr_election_date_input_dd", "abr_election_date_input_yyyy",
      "delivery_ballot_address_1", "delivery_ballot_address_2", "delivery_ballot_address_3"]
 
  def form_field_items
    [

      {"abr_reason_selections": { required: true, type: :radio }},

      {"abr_address_type_selections": {type: :radio, required: true}},
      {"abr_delivery_address_selections": {type: :radio, required: true}},
      {"abr_delivery_address_selections_abr_delivery_address_type2_instructions": {type: :instructions, visible: "abr_delivery_address_selections_abr_delivery_address_type2"}},
      {"abr_delivery_address_selections_abr_delivery_address_type3_instructions": {type: :instructions, visible: "abr_delivery_address_selections_abr_delivery_address_type3"}},
      {"abr_check_mailing_address": {type: :checkbox, visible: "abr_delivery_address_selections_abr_delivery_address_type1" }},      
      {"delivery_ballot_address_1": {required: :if_visible, visible: "abr_check_mailing_address"}},
      {"delivery_ballot_address_2": {visible: "abr_check_mailing_address"}},
      {"delivery_ballot_address_3": {required: :if_visible, visible: "abr_check_mailing_address"}},
      
      {"abr_request_name": { required: :if_visible, visible: "abr_delivery_address_selections_abr_delivery_address_type3" }},
      
      {"abr_election_type1": { type: :checkbox, visible_any: "abr_reason_selections_abr_reason2 abr_reason_selections_abr_reason3 abr_address_type_selections_abr_address_type2" }},
      {"abr_election_type_selections": { type: :radio, hidden: "abr_election_type1" }},
      {"abr_election_type1_instructions": {type: :instructions, visible: "abr_election_type1"}},
      {"abr_election_type2_instructions": {type: :instructions, visible: "abr_election_type_selections_abr_election_type2"}},
      {"abr_election_date_input": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type5"}},


      {"abr_assistant_check_selections": {type: :radio, required: true}},
      {"abr_assistant_name": {visible: "abr_assistant_check_selections_abr_assistant_check_option2", required: :if_visible}},
      {"abr_assistant_address_instructions": {type: :instructions,  visible: "abr_assistant_check_selections_abr_assistant_check_option2"}},
      {"abr_assistant_address_line1": {visible: "abr_assistant_check_selections_abr_assistant_check_option2", required: :if_visible}},
      {"abr_assistant_city": {visible: "abr_assistant_check_selections_abr_assistant_check_option2", required: :if_visible}},
      {"abr_assistant_state_abbrev": {visible: "abr_assistant_check_selections_abr_assistant_check_option2", required: :if_visible}},
      {"abr_assistant_zip": {visible: "abr_assistant_check_selections_abr_assistant_check_option2", required: :if_visible}},

    ]
  end

  def validate_form_fields
    super
    validate_state_abbrev_length
  end

  def mailing_addr_1
    if self.abr_delivery_address_selections_abr_delivery_address_type1
      delivery_ballot_address_1 || full_name
    else
      return ""
    end
  end
  
  def mailing_addr_2
    if self.abr_delivery_address_selections_abr_delivery_address_type1
      delivery_ballot_address_2 || address
    else
      return ""
    end
  end

  def mailing_addr_3
    if self.abr_delivery_address_selections_abr_delivery_address_type1
      delivery_ballot_address_3 || address_city_state_zip
    else
      return ""
    end
  end
  
  def abr_election_date_string
    date_field_string_mm_dd_yyyy(method: :abr_election_date_input)
  end

  # def mailing_addr_1=(value)
  #   self.delivery_ballot_address_1= value
  # end
  
  # def mailing_addr_2=(value)
  #   self.delivery_ballot_address_2= value
  # end

  # def mailing_addr_3=(value)
  #   self.delivery_ballot_address_3 = value
  # end

  def abr_assistant_check_option1
    abr_assistant_check_selections == 'abr_assistant_check_option1' ? 'abr_assistant_check_option1_value' : abr_assistant_check_selections
  end

  def abr_assistant_check_option2
    abr_assistant_check_selections == 'abr_assistant_check_option2' ? 'abr_assistant_check_option2_value' : abr_assistant_check_selections
  end
  
  def custom_form_field_validations
    before_validation :process_abbrev
  end
  
  private
  
  def process_abbrev
    if self.abr_assistant_state_abbrev.present?
      self.abr_assistant_state_abbrev = self.abr_assistant_state_abbrev[0..1].upcase
    end
  end

  def validate_state_abbrev_length
    if abr_assistant_state_abbrev.present? && abr_assistant_state_abbrev.length != 2
      errors.add(:abr_assistant_state_abbrev, "State must be exactly two characters long")
    end
  end
 
end