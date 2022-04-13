module AbrStateMethods::MD
  
    PDF_FIELDS = {

      "Last_Name": {},
      "First_Name": {},
      "Middle_Name": {},
      "suffix": { 
       #options: ["Off", "Yes", "Yes2", "Yes3", "Yes4", "Yes5"],
        method: "md_suffix_mapper"
      },

      "Birth_Month": {
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
      "Lic_1": {
        method: "dln_lic_1",
        sensitive:true
      },
      "Lic_2": {
        method: "dln_lic_2",
        sensitive:true
      },

      "Lic_3":  {
        method: "dln_lic_3",
        sensitive:true
      },

      "Lic_4":  {
        method: "dln_lic_4",
        sensitive:true
      },

      "Lic_5":  {
        method: "dln_lic_5",
        sensitive:true
      },


      "Birthdate": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Phone": {
        method: "phone"
      },
      "Del_Email": {
        method: "delivery_conditional_email"
      },

      "Gen_Address": {},
      "Gen_Apt": {},
      "Gen_City": {},
      "Gen_State": {},
      "Gen_ZipCode": {},
      "Email_address": {
        method: "email"
      },
      #"Issue_Date": {},
      "Issue_Month":{
        method: 'issue_date_mm'
      },
      "Issue_Day": {
        method: 'issue_date_dd'
      },
      "Issue_Year": {
        method: 'issue_date_yyyy'
      },

      "SSN_Last_4": {sensitive:true},

      "Fax_Area_Code": {
        method: 'fax_1'
      },
      "Fax_Phone": {
        method: 'fax_2'
      },
      "Fax_Phone_2": {
        method: 'fax_3'
      },
      "Today_Month": {method: "month_for_signature" },
      "Today_Day": {method: "day_for_signature" },
      "Today_Year": {method: "year_for_signature" },
      # "Todays_Date": { method: "date_for_signature" },
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
      "ZipCode": {
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

      "mailto": { options: ["Off","same_as_above", "address_below"] },

    }
    EXTRA_FIELDS = ["no_dln", "assistant", 'dln','issue_date','issue_date_mm','issue_date_dd','issue_date_yyyy','issue_date', "internet_delivery_identification",'movedate','movedate_mm','movedate_dd','movedate_yyyy','fax_number']
    
    # def whatever_it_is_you_came_up_with
    #   # TODO when blah is selected it should be "abc" and otherwise left blank
    # end
    
    
    def form_field_items
      [


        {"movedate": {type: :date,m: "movedate_mm", d: "movedate_dd", y: "movedate_yyyy",  required:'star'}},
       
        {"Delivery": {type: :radio, required: true}},
        {"internet_delivery_identification": {type: :radio, options: ['dln','ssn'], visible: "delivery_internet"}},
        {"dln": {visible: "internet_delivery_identification_dln", required: 'star', regexp: /\A[[:alpha:]]\d{12}\z/}},
        {"issue_date": {type: :date, m: "issue_date_mm", d: "issue_date_dd", y: "issue_date_yyyy", visible: "internet_delivery_identification_dln", required: 'star'}},
        #{"no_dln": {type: :checkbox, visible: "delivery_internet"}},
        {"SSN_Last_4": {visible: "internet_delivery_identification_ssn", required: 'star', regexp: /\A\d{4}\z/}},
        {"fax_number": {visible: "delivery_fax", required: 'star', regexp: /\A\d{3}-\d{3}-\d{4}\z/ }},
        {"mailto": {type: :radio, options: ["same_as_above", "address_below"], required: 'star', visible: "delivery_mail"}},
        {"Gen_Address": {visible: "mailto_address_below",required: 'star', classes: "three-quarter"}},
        {"Gen_Apt": {visible: "mailto_address_below", classes: "quarter last"}},
        {"Gen_City": {visible: "mailto_address_below",required: 'star', classes: "half"}},
        {"Gen_State": {visible: "mailto_address_below",required: 'star', classes: "quarter", type: :select, options: GeoState.collection_for_select}},
        {"Gen_ZipCode": {visible: "mailto_address_below",required: 'star', classes: "quarter last"}},
        #{"assistant": {type: :checkbox}}, # Removing until we can make esign conditional
        #{"Assistance_Print_Name": {visible: "assistant", required: :if_visible}},

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

    def issue_date_mm_dd_yyyy
      dates = [issue_date_mm, issue_date_dd, issue_date_yyyy].collect {|d| d.blank? ? nil : d}.compact
      dates && dates.length == 3 ? dates.join("/") : nil
    end

    def movedate_dd_optional
      self.movedate_dd.to_s !='' ? movedate_dd.to_s : '01'
    end
    
    def movedate_mm_dd_yyyy
      dates = [movedate_mm, movedate_dd_optional, movedate_yyyy].collect {|d| d.blank? ? nil : d}.compact
      dates && dates.length == 3 ? dates.join("/") : nil
    end

    def md_suffix_mapper
      case self.name_suffix
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

    def dln_lic_1
      return dln.to_s[0..1] if dln.to_s!=''
    end

    def dln_lic_2
      return dln.to_s[1..3] if dln.to_s!=''
    end
    def dln_lic_3
      return dln.to_s[4..6] if dln.to_s!=''
    end
    def dln_lic_4
      return dln.to_s[7..9] if dln.to_s!=''
    end
    def dln_lic_5
      return dln.to_s[10..12] if dln.to_s!=''
    end

    def fax_1
      return fax_number.to_s[0..2] if fax_number.to_s!=''
    end

    def fax_2
      return fax_number.to_s[4..6] if fax_number.to_s!=''
    end

    def fax_3
      return fax_number.to_s[8..11] if fax_number.to_s!=''
    end

    def delivery_conditional_email
      return self.email if self.delivery.to_s=="internet"
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
    
    def test_date(datestring)
      begin
        @mydate = Date.strptime(datestring, "%m/%d/%Y")
        return true
      rescue ArgumentError
        return false
      end
    end

    REQUIRED_MAIL_FIELDS = [
      "Gen_Address",
      "Gen_City",
      "Gen_State",
      "Gen_ZipCode",
      ]

    def require_mailing_fields
      REQUIRED_MAIL_FIELDS.each do |f|
        custom_validates_presence_of(f)
      end
    end
    
    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery

      #dln
      #issue_date_mm_dd_yyyy

      if (self.internet_delivery_identification.to_s=='dln') 
        custom_validates_presence_of('dln') 
        if !self.test_date(self.issue_date_mm_dd_yyyy.to_s)
          errors.add("issue_date", custom_format_message("bad_date") )
          errors.add('issue_date', self.issue_date_mm_dd_yyyy.to_s)
        end
      end

      #SSN_Last_4
      if (self.internet_delivery_identification.to_s=='ssn') 
        custom_validates_presence_of('SSN_Last_4') 
      end
      

      if (self.delivery.to_s=='fax') 
        custom_validates_presence_of('fax_number') 
      end

      if (self.mailto.to_s=='address_below') 
        self.require_mailing_fields 
      end      

      #movedate_mm_dd_yyyy
      if !self.test_date(self.movedate_mm_dd_yyyy.to_s)
        errors.add("movedate", custom_format_message("bad_date") )
        errors.add('movedate', self.movedate_mm_dd_yyyy.to_s)
      end

    end
   
   
  end
  