module AbrStateMethods::ND
  
    PDF_FIELDS = {
      "Date of Birth": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Daytime Telephone Number": {
        method: "phone"
      },
      "Residential Address": {
        method: "address"
      },
      "City": {
        method: "city"
      },
      "State": {
        method: "home_state_abbrev"
      },
      "ZIP Code": {
        method: "zip"
      },
      "City_2": {},
      "State_2": {},
      "ZIP Code_2": {},
      #"Date": {}
      "Printed Name of Attester": {},
      "Daytime Telephone Number_2": {},
      "election": { 
        options: ["All_Statewide", "City", "General", "Primary", "School", "Special"],
        value: "General"
      },
      "Name": {
        method: "full_name"
      },
      "ID_Type": { options: ["drivers_license", "long_term_care_certificate", "non_drivers_id", "passport_or_military_id", "tribal_id", "no_id"] },
      "ID_Number": {},
      "Ballot_Delivery_Address": {},
      "Voters_Mark": { options: ["Off", "Yes"] }, #TODO - if "unable_to_sign" (created below) is selected, then value: "Yes", otherwise value: "Off"
      "markers_printed_name": {
        method: "voter_name"
      },
      "Military_Overseas_Voter": { options: ["Military_in_US", "Military_outside_US", "citizen_outside_us"] },
      "email": {
        method: "uocava_email" #TODO - see below
      },
      "Preferred_Delivery": { options: ["Email", "Mail", "Fax"] },
      "Fax_Number": {},
      "Attestor_ID": {},
    }
    EXTRA_FIELDS = ["has_mailing_address", "uocava", "unable_to_sign"]
    
    # def uocava_email
    #   # TODO when "Preferred_Delivery_Email" is selected it should autofill with "email" and otherwise left blank
    # end
  
    # def "voter_name"
    #   # TODO when "unable_to_sign" (created below) is selected, it should autofill with "full_name" of voter and otherwise left blank
    # end
    
    
    def form_field_items
      [
        {"ID_Type": {type: :radio, required: true}},
        {"Printed Name of Attester": {visible: "id_type_no_id", required: :if_visible}},
        {"Attestor_ID": {visible: "id_type_no_id", required: :if_visible, classes: "half"}},
        {"Daytime Telephone Number_2": {visible: "id_type_no_id", required: :if_visible, classes: "half last"}},
        {"ID_Number": {}},
        {"has_mailing_address": {type: :checkbox}},
        {"Ballot_Delivery_Address": {visible: "has_mailing_address"}},
        {"City_2": {visible: "has_mailing_address", classes: "half"}},
        {"State_2": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"ZIP Code_2": {visible: "has_mailing_address", classes: "quarter last"}},
        {"uocava": {type: :checkbox}},
        {"Military_Overseas_Voter": {visible: "uocava", type: :radio, required: :if_visible}},
        {"Preferred_Delivery": {visible: "uocava", type: :radio, required: :if_visible}},
        {"Fax_Number": {visible: "preferred_delivery_fax", required: :if_visible}},
        {"unable_to_sign": {type: :checkbox}},
      ]
    end
    #e.g.
    # [
    #   {"reason_instructions": {type: :instructions}}, *"reason_instructions" does NOT get put into EXTRA_FIELDS
    #   {"County": {type: :select, required: true, include_blank: true, options: [
    #     "Adams",
    #   ]}},
    #   {"Security Number": {required: true}},
    #   {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true, }},
    #   {"ZIP_2": {visible: "has_mailing_address", min: 5, max: 10}},
    #   {"identification": {
    #     type: :radio,
    #     required: true,
    #     options: ["dln", "ssn4", "photoid"]}},
    #   {"OR": {visible: "identification_dln", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}\d{6}\z/}},
    #   {"OR_2": {visible: "identification_ssn4", min: 4, max: 4, regexp: /\A\d{4}\z/}},
    # ]
    
    
    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery
    end
    
   
  end
  