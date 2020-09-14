module AbrStateMethods::MD
  
    PDF_FIELDS = {
      "Maryland Drivers License or ID Card Number": {},
      "Birthdate": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Phone": {
        method: "phone"
      },
      "Address_2": {},
      "Apt_number_2": {},
      "City_town_2": {},
      "State_2": {},
      "ZIP_code_2": {},
      "Email_address": {
        method: "email"
      },
      "Issue_Date": {},
      "SSN_last-4": {},
      #"Todays_Date": {},
      #"assistant_sign": {},
      "assistant_print": {},
      "Current_Address": {
        method: "address_line_1"
      },
      "Current_Apt number": {
        method: "unit"
      },
      "Current_City_town": {
        method: "city"
      },
      "Current_State": {
        method: "home_state_abbrev"
      },
      "Current_ZIP_code": {
        method: "zip"
      },
      "When_Moved_Here": {},
      "Special_Primary": { 
        options: ["Off", "Yes"],
        value: "Off"
      },
      "Presidential_Primary": { 
        options: ["Off", "Yes"],
        value: "Off"
      },
      "Presidential_General": { 
        options: ["Off", "Yes"],
        value: "Yes"
      },
      "All_Elections": { 
        options: ["Off", "Yes"],
        value: "Off"
      },
      #"voter_signature": {},
      "print_name": {
        method: "full_name"
      },
      "delivery_method": { options: ["mail", "internet"] },
      "primary_mailto": { 
        options: ["Off", "address_below", "same_as_above"],
        value: "Off"
      },
      "presidential_primary_mailto": { 
        options: ["Off", "address_below", "same_as_above"],
        value: "Off"
      },
      "presidential_general_mailto": { options: ["same_as_above", "address_below"] },
    }
    EXTRA_FIELDS = ["no_dln", "assistant"]
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [
        {"When_Moved_Here": {min: 7, max: 10}},
        {"delivery_method": {type: :radio, required: true}},
        {"Maryland Drivers License or ID Card Number": {visible: "delivery_method_internet"}},
        {"Issue_Date": {visible: "delivery_method_internet"}},
        {"no_dln": {type: :checkbox, visible: "delivery_method_internet"}},
        {"SSN_last-4": {visible: "no_dln", required: :if_visible}},
        {"presidential_general_mailto": {type: :radio, required: :if_visible, visible: "delivery_method_mail"}},
        {"Address_2": {visible: "presidential_general_mailto_address_below", classes: "three-quarter"}},
        {"Apt_number_2": {visible: "presidential_general_mailto_address_below", classes: "quarter last"}},
        {"City_town_2": {visible: "presidential_general_mailto_address_below", classes: "half"}},
        {"State_2": {visible: "presidential_general_mailto_address_below", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"ZIP_code_2": {visible: "presidential_general_mailto_address_below", classes: "quarter last"}},
        {"assistant": {type: :checkbox}},
        {"assistant_print": {visible: "assistant", required: :if_visible}},
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
  