module AbrStateMethods::PA
  
    PDF_FIELDS = {
      "Birth date": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      "Zip code": {
        method: "zip"
      },
      "State": {},
      "Zip code_2": {},
      "PA drivers license or PennDOT ID card number": {},
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
      "Phone_Number": {
        method: "phone"
      },
      "Email_Address": {
        method: "email"
      },
      "Apt_number": {
        method: "unit"
      },
      "County": {},
      "Municipality": {},
      "Lived_at_Address_Since": {},
      "Address": {
        method: "address_line_1"
      },
      "Address_1": {},
      "City_Town": {},
      "City_Town_1": {},
      "SSN_last_4": {},
      "no_id": {},
      "Same_as_above": { options: ["Off", "On"] },
    }
    EXTRA_FIELDS = ["no_PennDOT"]
    
    
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
        {"Lived_at_Address_Since": {required: true}},
        {"PA drivers license or PennDOT ID card number": {}},
        {"no_PennDOT": {type: :checkbox}},
        {"SSN_last_4": {visible: "no_PennDOT"}},
        {"no_id": {type: :checkbox, visible: "no_PennDOT"}},
        {"Same_as_above": {type: :radio}},
        {"Address_1": {visible: "same_as_above_off"}},
        {"City_Town_1": {visible: "same_as_above_off", classes: "half"}},
        {"State": {visible: "same_as_above_off", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"Zip code_2": {visible: "same_as_above_off", classes: "quarter last"}},
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
  