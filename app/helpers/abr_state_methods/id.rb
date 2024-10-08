module AbrStateMethods::ID

    
    PDF_FIELDS = {
      "abr_email": {
        method: "email"
      },
      #"abr_reason_instructions"	
      "abr_first_name": {
        method: "first_name"
      },
      "abr_middle_initial": {
        method: "middle_initial"
      },
      "abr_last_name": {
        method: "last_name"
      },
      "abr_name_suffix": {
        method: "name_suffix"
      },
      "abr_date_of_birth_mm_dd_yyyy": {
        method: "date_of_birth_mm_dd_yyyy"
      },
      'abr_street_name': { 
        method: "address_line_1"
      },
      "abr_unit": {
        method: "unit"
      },
      "abr_city": {
        method: "city"
      },
      "abr_home_state_abbrev": {
        method: "home_state_abbrev"
      },
      "abr_zip": {
        method: "zip"
      },
      "abr_county": {},
      # "abr_id_selections": {
      #   options: [
      #     "abr_id_type1",
      #     "abr_id_no1",          
      #   ]
      # }
      #"abr_check_mailing_address": {},
      #"abr_mailing_address_instructions": {},
      "abr_mailing_address_line_1": {},
      "abr_mailling_city": {},
      "abr_mailing_state_abbrev": {},
      "abr_mailing_zip": {},
      "abr_mailing_country": {},
      "abr_election_type1": {
        options: ["Off", "Yes"]
      },
      "abr_election_type2": {
        options: ["Off", "Yes"]
      },
      "abr_election_type3": {
        options: ["Off", "Yes"]
      },
      "abr_primary_type_selections1": {
        options: [
          "abr_primary_type1",
          "abr_primary_type2",
          "abr_primary_type3",
          "abr_primary_type4",
          "NonPartisan",    
        ]
      },
      "abr_phone": {
        method: "phone"
      }

    }
    EXTRA_FIELDS = ["abr_check_mailing_address"]
  
    COUNTIES = [
      "Ada County",
        "Adams County",
        "Bannock County",
        "Bear Lake County",
        "Benewah County",
        "Bingham County",
        "Blaine County",
        "Boise County",
        "Bonner County",
        "Bonneville County",
        "Boundary County",
        "Butte County",
        "Camas County",
        "Canyon County",
        "Caribou County",
        "Cassia County",
        "Clark County",
        "Clearwater County",
        "Custer County",
        "Elmore County",
        "Franklin County",
        "Fremont County",
        "Gem County",
        "Gooding County",
        "Idaho County",
        "Jefferson County",
        "Jerome County",
        "Kootenai County",
        "Latah County",
        "Lemhi County",
        "Lewis County",
        "Lincoln County",
        "Madison County",
        "Minidoka County",
        "Nez Perce County",
        "Oneida County",
        "Owyhee County",
        "Payette County",
        "Power County",
        "Shoshone County",
        "Teton County",
        "Twin Falls County",
        "Valley County",
        "Washington County",
    ]
    
    COUNTRIES = [
      "Afghanistan",
          "Albania",
          "Algeria",
          "Andorra",
          "Angola",
          "Antigua and Barbuda",
          "Argentina",
          "Armenia",
          "Australia",
          "Austria",
          "Azerbaijan",
          "Bahamas",
          "Bahrain",
          "Bangladesh",
          "Barbados",
          "Belarus",
          "Belgium",
          "Belize",
          "Benin",
          "Bhutan",
          "Bolivia",
          "Bosnia and Herzegovina",
          "Botswana",
          "Brazil",
          "Brunei Darussalam",
          "Bulgaria",
          "Burkina Faso",
          "Burundi",
          "Cambodia",
          "Cameroon",
          "Canada",
          "Cape Verde",
          "Central African Republic",
          "Chad",
          "Chile",
          "China",
          "Colombia",
          "Comoros",
          "Congo",
          "Congo (Democratic Republic of the)",
          "Costa Rica",
          "Côte d'Ivoire",
          "Croatia",
          "Cuba",
          "Cyprus",
          "Czech Republic",
          "Denmark",
          "Djibouti",
          "Dominica",
          "Dominican Republic",
          "Ecuador",
          "Egypt",
          "El Salvador",
          "Equatorial Guinea",
          "Eritrea",
          "Estonia",
          "Ethiopia",
          "Fiji",
          "Finland",
          "France",
          "Gabon",
          "Gambia",
          "Georgia",
          "Germany",
          "Ghana",
          "Greece",
          "Grenada",
          "Guatemala",
          "Guinea",
          "Guinea-Bissau",
          "Guyana",
          "Haiti",
          "Honduras",
          "Hungary",
          "Iceland",
          "India",
          "Indonesia",
          "Iran (Islamic Republic of)",
          "Iraq",
          "Ireland",
          "Israel",
          "Italy",
          "Jamaica",
          "Japan",
          "Jordan",
          "Kazakhstan",
          "Kenya",
          "Kiribati",
          "Korea (Democratic People's Republic of)",
          "Korea (Republic of)",
          "Kuwait",
          "Kyrgyzstan",
          "Lao People's Democratic Republic",
          "Latvia",
          "Lebanon",
          "Lesotho",
          "Liberia",
          "Libya",
          "Liechtenstein",
          "Lithuania",
          "Luxembourg",
          "Macedonia (The former Yugoslav Republic of)",
          "Madagascar",
          "Malawi",
          "Malaysia",
          "Maldives",
          "Mali",
          "Malta",
          "Marshall Islands",
          "Mauritania",
          "Mauritius",
          "Mexico",
          "Micronesia (Federated States of)",
          "Republic of Moldova",
          "Monaco",
          "Mongolia",
          "Montenegro",
          "Morocco",
          "Mozambique",
          "Myanmar",
          "Namibia",
          "Nauru",
          "Nepal",
          "Netherlands",
          "New Zealand",
          "Nicaragua",
          "Niger",
          "Nigeria",
          "Norway",
          "Oman",
          "Pakistan",
          "Palau",
          "Panama",
          "Papua New Guinea",
          "Paraguay",
          "Peru",
          "Philippines",
          "Poland",
          "Portugal",
          "Qatar",
          "Romania",
          "Russian Federation",
          "Rwanda",
          "Saint Kitts and Nevis",
          "Saint Lucia",
          "Saint Vincent and the Grenadines",
          "Samoa",
          "San Marino",
          "Sao Tome and Principe",
          "Saudi Arabia",
          "Senegal",
          "Serbia",
          "Seychelles",
          "Sierra Leone",
          "Singapore",
          "Slovakia",
          "Slovenia",
          "Solomon Islands",
          "Somalia",
          "South Africa",
          "South Sudan",
          "Spain",
          "Sri Lanka",
          "Sudan",
          "Suriname",
          "Swaziland",
          "Sweden",
          "Switzerland",
          "Syrian Arab Republic",
          "Tajikistan",
          "Tanzania (United Republic of)",
          "Thailand",
          "Timor-Leste",
          "Togo",
          "Tonga",
          "Trinidad and Tobago",
          "Tunisia",
          "Turkey",
          "Turkmenistan",
          "Tuvalu",
          "Uganda",
          "Ukraine",
          "United Arab Emirates",
          "United Kingdom of Great Britain and Northern Ireland",
          "United States of America",
          "Uruguay",
          "Uzbekistan",
          "Vanuatu",
          "Venezuela (Bolivarian Republic of)",
          "Viet Nam",
          "Yemen",
          "Zambia",
          "Zimbabwe",
    ]

    def form_field_items
      [
        {"abr_county": {type: :select, options: COUNTIES, include_blank: true, required: true}},
        {"abr_check_mailing_address": {type: :checkbox}},
        {"abr_mailing_address_instructions": {type: :instructions, visible:  "abr_check_mailing_address"}},
        {"abr_mailing_address_line_1": {visible: "abr_check_mailing_address", required: :if_visible}},        
        {"abr_mailling_city": {visible: "abr_check_mailing_address", required: :if_visible, classes: "half"}},        
        {"abr_mailing_state_abbrev": {visible: "abr_check_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select}},        
        {"abr_mailing_zip": {visible: "abr_check_mailing_address", required: :if_visible, classes: "quarter last"}},
        {"abr_mailing_country": {visible: "abr_check_mailing_address", type: :select, include_blank: true, options: COUNTRIES }},
        {"abr_election_type_selection": {type: :instructions}},
        {"abr_election_type1": { type: :checkbox}},
        {"abr_election_type2": { type: :checkbox}},
        {"abr_election_type3": { type: :checkbox}},
        {"abr_primary_type_selections1": { type: :radio, required: :if_visible, visible: "abr_election_type1"}}
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
  