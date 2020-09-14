module AbrStateMethods::MD
  
    PDF_FIELDS = {

      "Last_Name": {},
      "First_Name": {},
      "Middle_Name": {},
      "suffix": { 
        options: ["Off", "Yes", "Yes2", "Yes3", "Yes4", "Yes5"],
        method: "md_suffix_mapper"
      },

      "Birth_Month" {
        method: "date_of_birth_mm"
      },
      "Birth_Day": {
        method: "date_of_birth_dd"
      },

      "Birth_Year": {
        method: "date_of_birth_yyyy"
      },

      "Email": {
        method: "email"
      },

      "Area_Code": {
        method: "phone_area"
      },
      "Phone_1": {
        method: "phone_prefix"
      },
      "Phone_2": {
        method: "phone_last4"
      },
      
      "Move_Month": {
        method: "movedate_mm"
      },
      "Move_Day": {
        method: "movedate_dd"
      },
      "Move_Year": {
        method: "movedate_yyyy"
      },

      #"Maryland Drivers License or ID Card Number": {sensitive:true},
      "Lic_1": {sensitive:true},
      "Lic_2": {sensitive:true},
      "Lic_3": {sensitive:true},
      "Lic_4": {sensitive:true},
      "Lic_5": {sensitive:true},

      "Birthdate": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Phone": {
        method: "phone"
      },
      "Del_Email": {
        method: "delivery_conditional_email"
      }

      "Gen_Address": {},
      "Gen_Apt": {},
      "Gen_City": {},
      "Gen_State": {},
      "Gen_ZipCode": {},
      "Email_address": {
        method: "email"
      },
      "Issue_Date": {},
      "Issue_Month":{},
      "Issue_Day": {},
      "Issue_Year": {},

      "SSN_Last_4": {sensitive:true},

      "Fax_Area_Code": {}
      "Fax_Phone": {}
      "Fax_Phone_2": {}
      #"Todays_Date": {},
      #"assistant_sign": {},
      #"assistant_print": {},
      'Assistance_Print_Name': {},
      "Address": {
        method: "address_line_1"
      },
      "Apt": {
        method: "unit"
      },
      "City": {
        method: "city"
      },
      "State": {
        method: "home_state_abbrev"
      },
      "Zipcode": {
        method: "zip"
      },
    #"When_Moved_Here": {},
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
      "Delivery": { options: ["mail", "internet", "fax"] },
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
    EXTRA_FIELDS = ["no_dln", "assistant", "dln", 'issue_date', "internet_delivery_identification"]
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [


        {"When_Moved_Here": {min: 7, max: 10, regexp: /\A(\d{2}\/\d{4}|\d{2}\/\d{2}\/\d{4})\z/, required:true}},
        {"delivery_method": {type: :radio, required: true}},
        {"internet_delivery_identification": {type:radio, options: ['dln','ssn'], visible: "delivery_method_internet"}}
        {"dln": {visible: "delivery_method_internet_dln"}},
        {"issue_date": {visible: "delivery_method_internet_dln", regexp: /\A(\d{2}\/\d{2}\/\d{4})\z/,}},
        #{"no_dln": {type: :checkbox, visible: "delivery_method_internet"}},
        {"SSN_Last_4": {visible: "delivery_method_internet_ssn", required: :if_visible}},
        {"fax": {visible: "delivery_method_fax"}},
        {"presidential_general_mailto": {type: :radio, required: 'star', visible: "delivery_method_mail"}},
        {"Gen_Address": {visible: "presidential_general_mailto_address_below", classes: "three-quarter"}},
        {"Gen_Apt": {visible: "presidential_general_mailto_address_below", classes: "quarter last"}},
        {"Gen_City": {visible: "presidential_general_mailto_address_below", classes: "half"}},
        {"Gen_State": {visible: "presidential_general_mailto_address_below", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"Gen_ZipCode": {visible: "presidential_general_mailto_address_below", classes: "quarter last"}},
        {"assistant": {type: :checkbox}},
        {"Assistance_Print_Name": {visible: "assistant", required: :if_visible}},
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
    

    def md_suffix_mapper
      case self.suffix
        when "Jr."
          "Yes"
        when "Sr."
          "Yes2"
        when "II"
          "Yes3"
        when "III"
          "Yes4"
        when "IV"
          "Yes5"
        else
          "Off"
      end
    end

    def delivery_conditional_email
      return self.email if self.delivery.to_s=="email"
    end

    def phone_area
      if self.phone.to_s!=''   
        return (phone_digits[0..2])
      end
    end
  
    def phone_prefix
      if self.phone.to_s!=''
        return (phone_digits[3..5])
      end
    end
    
    def phone_last4
      if self.phone.to_s!=''
        return (phone_digits[6..9])
      end
    end 

    def movedate_mm
      if self.movedate.to_s!=''
        return (movedate.to_s[1..2])
      end
    end

    def movedate_dd
      if self.movedate.to_s.length>5
        return (movedate.to_s[4..5])
      end
    end

    def movedate_yy
      if self.movedate.to_s!=''
        return (movedate.to_s.chars.last(n=4).join
      end
    end
    
    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery

      #dln

      #SSN_Last_4

    end
    
   
  end
  