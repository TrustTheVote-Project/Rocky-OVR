module AbrStateMethods::PA
  
    PDF_FIELDS = {
      "Birth date": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Zip": {
        method: "zip"
      },
      "State": {},
      "Zip code_2": {},
      "PA drivers license or PennDOT ID card number": {sensitive:true},
      "Last_Name": {
        method: "last_name"
      },
      "First_Name": {
        method: "first_name"
      },
      "Name_suffix": {
        method: "name_suffix"
      },
      "Middle_Name_or_Initial": {
        method: "middle_initial"
      },
      "Phone": {
        method: "phone"
      },
      "Email": {
        method: "email"
      },
      "Apt_number": {
        method: "unit"
      },
      "County": {},
      "Municipality": {},
      "Lived_at_Address_Since": {
        method: 'address_date_mm_dd_yyyy'
      },
      "Address": {
        method: "address_line_1"
      },
      "Address_1": {},
      "City": { method: "city"},
      "City_Town_1": {},
      "Mailing_Address_Type": {},
      "SSN_last_4": {sensitive:true, method: 'ssn_if_not_no_id'},
      "no_id": {
        options: ["Yes", "Off"],
        method: "check_assert_no_id"
      },
      "Same_as_above": { options: ["On", "Off"] },
      "annual_request": {
        options: ["Yes", "Off"]
      },
      "Address of witness": {}


    }
    EXTRA_FIELDS = ["has_assistance", "no_PennDOT", "assert_no_id", 'ssn_last_4_input', 'identification', 'identification2','address_date','address_date_mm', 'address_date_dd','address_date_yyyy']
    
    
    def form_field_items
      [
        {"County": {type: :select, required: true, include_blank: true, options: [
          "Adams",
          "Allegheny",
          "Armstrong",
          "Beaver",
          "Bedford",
          "Berks",
          "Blair",
          "Bradford",
          "Bucks",
          "Butler",
          "Cambria",
          "Cameron",
          "Carbon",
          "Centre",
          "Chester",
          "Clarion",
          "Clearfield",
          "Clinton",
          "Columbia",
          "Crawford",
          "Cumberland",
          "Dauphin",
          "Delaware",
          "Elk",
          "Erie",
          "Fayette",
          "Forest",
          "Franklin",
          "Fulton",
          "Greene",
          "Huntingdon",
          "Indiana",
          "Jefferson",
          "Juniata",
          "Lackawanna",
          "Lancaster",
          "Lawrence",
          "Lebanon",
          "Lehigh",
          "Luzerne",
          "Lycoming",
          "McKean",
          "Mercer",
          "Mifflin",
          "Monroe",
          "Montgomery",
          "Montour",
          "Northampton",
          "Northumberland",
          "Perry",
          "Philadelphia",
          "Pike",
          "Potter",
          "Schuylkill",
          "Snyder",
          "Somerset",
          "Sullivan",
          "Susquehanna",
          "Tioga",
          "Union",
          "Venango",
          "Warren",
          "Washington",
          "Wayne",
          "Westmoreland",
          "Wyoming",
          "York",
        ]}},
        {"Municipality": {}},
        {"address_date": {required: true,type: :date, m: "address_date_mm", d: "address_date_dd", y: "address_date_yyyy", }}, #regexp: /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/}},
        {"identification": {required: true, type: :radio, options: ['dln', 'no_dln']}},
        {"PA drivers license or PennDOT ID card number": {regexp: /\A\d{8}\z/, length:8, visible: "identification_dln"}},
        {"identification2": {visible: "identification_no_dln", required: 'star', type: :radio, options: ['ssn', 'no_ssn']}},
        #{"no_PennDOT": {type: :checkbox}},

        {"ssn_last_4_input": {visible: "identification2_ssn", classes:"half", length:4,regexp: /\A[0-9]{4}\z/}},
        {"assert_no_id": {type: :checkbox, visible: "identification2_no_ssn", required: 'star'}},
        
        {"Same_as_above": {type: :radio, required: true}},
        {"Address_1": {visible: "same_as_above_off", required: 'star'}},
        {"City_Town_1": {visible: "same_as_above_off", classes: "half", required:'star'}},
        {"State": {visible: "same_as_above_off", required: 'star', classes: "quarter", type: :select, options: GeoState.collection_for_select}},
        {"Zip code_2": {visible: "same_as_above_off", required:'star', classes: "quarter last"}},
        {"Mailing_Address_Type":  {visible: "same_as_above_off", required:'star'}},
        {"annual_request": {type: :radio}},
        {"has_assistance": {type: :checkbox}},
        {"Address of witness": {visible: "has_assistance", required: :if_visible}}
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
    
    def check_assert_no_id
        return ("Yes") if self.assert_no_id.to_s=='1'
        return "Off"
    end

    def ssn_if_not_no_id
      # Fill SSN if no driver's license, but no id is not selected
      return self.ssn_last_4_input if self.identification2.to_s=='ssn' #(self.assert_no_id.to_s!='1' && self.no_PennDOT.to_s=='1')
    end

    REQUIRED_MAILING_ADDRESS_FIELDS = [
        "Address_1",
        "City_Town_1",
        "State",
        "Zip code_2",
      ]
    
      def require_mailing_fields
        REQUIRED_MAILING_ADDRESS_FIELDS.each do |field|
          custom_validates_presence_of(field)
        end
      end

      def address_date_mm_dd_yyyy
        dates = [address_date_mm, address_date_dd, address_date_yyyy].collect {|d| d.blank? ? nil : d}.compact
        dates && dates.length == 3 ? dates.join("/") : nil
      end
      
      def test_date(datestring)
        begin
          @mydate = Date.strptime(datestring, "%m/%d/%Y")
          return true
        rescue ArgumentError
          return false
        end
      end

    
    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery
      if (self.identification.to_s=='dln')
        custom_validates_presence_of('PA drivers license or PennDOT ID card number')  
      elsif (self.identification2.to_s=='ssn')
        custom_validates_presence_of('ssn_last_4_input')
      else
        custom_validates_presence_of('assert_no_id') #this doesn't work
        if (self.assert_no_id.to_s!='1')
          errors.add("assert_no_id", custom_required_message("assert_no_id") )
        end
      end

        #if !(self.ssn_last_4_input.to_s =~ /\A\d{4}\z/)
        #    errors.add('ssn_last_4_input', custom_format_message('ssn_last_4_input'))
        #end

      #end

      if self.same_as_above.to_s=='Off'
        require_mailing_fields
             
      end

      if !self.test_date(self.address_date_mm_dd_yyyy.to_s)
        errors.add("address_date", custom_format_message("bad_date") )
        errors.add('address_date', self.address_date_mm_dd_yyyy.to_s)
      end



    end
    
   
  end
  