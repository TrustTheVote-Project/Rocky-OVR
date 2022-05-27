module AbrStateMethods::MT
  
  PDF_FIELDS = {'abr_last_name': {:method=>"last_name"},
                'abr_first_name': {:method=>"first_name"},
                'abr_middle_name': {method: "middle_name"},
                'abr_phone': {method: "phone"},
                'abr_street_number': {method: "street_number"},
                'abr_street_name': {method: "street_name"},
                'abr_city': {:method=>"city"},
                'abr_zip': {:method=>"zip"},
                'abr_unit': {:method=>"unit"},
                
                'abr_county': {},
                'abr_mailing_street_number': {},
                'abr_mailing_street_name': {},
                'abr_mailing_city': {},
                'abr_mailing_state_abbrev': {},
                'abr_mailing_unit': {},
                'abr_mailing_zip': {},
                'abr_election_type_selections': {
                  options: [
                    "abr_election_type1",
                    "abr_election_type2",
                  ]
                },
                'abr_election_type_selections2': {
                  options: [
                    "abr_election_type3",
                    "abr_election_type4",
                    "abr_election_type5",
                    "abr_election_type6",
                  ]
                },
                'abr_election_type6_name': {},
                'abr_election_date': {method: "abr_election_date_string"},
                'abr_request_name': {},
                'abr.email': { method: "email"},
                'abr_date_of_birth_mm_dd_yyyy': {
                  method: "date_of_birth_mm_dd_yyyy",
                  pdf_name: "date_of_birth_mm_dd_yyyy"
                },
               }

  EXTRA_FIELDS = ["abr_check_mailing_address", "abr_request_check", "abr_election_date_input_mm", "abr_election_date_input_dd", "abr_election_date_input_yyyy"]
  
  
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Beaverhead",
        "Big Horn",
        "Blaine",
        "Broadwater",
        "Carbon",
        "Carter",
        "Cascade",
        "Chouteau",
        "Custer",
        "Daniels",
        "Dawson",
        "Deer Lodge",
        "Fallon",
        "Fergus",
        "Flathead",
        "Gallatin",
        "Garfield",
        "Glacier",
        "Golden Valley",
        "Granite",
        "Hill",
        "Jefferson",
        "Judith Basin",
        "Lake",
        "Lewis And Clark",
        "Liberty",
        "Lincoln",
        "Madison",
        "McCone",
        "Meagher",
        "Mineral",
        "Missoula",
        "Musselshell",
        "Park",
        "Petroleum",
        "Phillips",
        "Pondera",
        "Powder River",
        "Powell",
        "Prairie",
        "Ravalli",
        "Richland",
        "Roosevelt",
        "Rosebud",
        "Sanders",
        "Sheridan",
        "Silver Bow",
        "Stillwater",
        "Sweet Grass",
        "Teton",
        "Toole",
        "Treasure",
        "Valley",
        "Wheatland",
        "Wibaux",
        "Yellowstone",
        "Yellowstone National Park",
      ]}},
      {'abr_check_mailing_address': {type: :checkbox}},
      {'abr_mailing_street_number': {required: :if_visible, visible: "abr_check_mailing_address", classes: "quarter"}},
      {'abr_mailing_street_name': {required: :if_visible, visible: "abr_check_mailing_address", classes: "half"}},
      {'abr_mailing_unit': {visible: "abr_check_mailing_address", classes: "quarter"}},
      {'abr_mailing_city': {required: :if_visible, visible: "abr_check_mailing_address", classes: "half"}},
      {'abr_mailing_state_abbrev': {type: :select, required: :if_visible, visible: "abr_check_mailing_address", classes: "quarter", options: GeoState.collection_for_select}},
      {'abr_mailing_zip': {required: :if_visible, visible: "abr_check_mailing_address", classes: "quarter"}},
      {'abr_election_type_selections': {type: :radio, required: true}},
      {'abr_election_type_selections2': {type: :radio, required: :if_visible, visible: "abr_election_type_selections_abr_election_type2"}},
      {'abr_election_type6_name': {required: :if_visible, visible: "abr_election_type_selections2_abr_election_type6"}},
      {'abr_election_date_input':  {type: :date, required: :if_visible, visible: "abr_election_type_selections2_abr_election_type6"}},
      {'abr_request_check': {type: :checkbox}},
      {'abr_request_name': {required: :if_visible, visible: "abr_request_check"}},
    ]
  end
  
  
  def custom_form_field_validations
  end

  def abr_election_date_string
    date_field_string_mm_dd_yyyy(method: :abr_election_date_input)
  end

  
 
end
