module AbrStateMethods::MD
  
  PDF_FIELDS = {'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {},
                'abr_last_name': {:method=>"last_name"},
                'abr_name_suffix': {:method=>"name_suffix"},
                'date_of_birth_mm_dd_yyyy': {},
                'abr_street_number': {},
                'abr_street_name': {},
                'abr_unit': {:method=>"unit"},

                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                'abr_address_type_selections': {},
                'abr_fax_number': {},
                'abr_drivers_license': {},
                'abr_id_date': {},
                'abr_last_4_ssn': {},
                'abr_address_type5': {},
                'abr_mailing_address_line_1': {},
                'abr_mailing_unit': {},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_zip': {},
                'abr_election_type_selections': {},
                'abr_primary_type_selections': {},
                'abr_primary_type7_name': {},
                'abr_contact_method_selections': {},
                'abr_delivery_email': {}
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
  
