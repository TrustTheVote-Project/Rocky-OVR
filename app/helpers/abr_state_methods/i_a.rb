module AbrStateMethods::IA
  
  
  PDF_FIELDS = {
    "Email Address": { method: "email" },
    "Phone Number": {method: "phone"},
    "abr_first_name": { method: "first_name" },
    "abr_middle_name": { method: "middle_name"},
    "abr_last_name": { method: "last_name"},
    "abr_name_suffix": { method: "name_suffix" },
    "abr_date_of_birth_month": {
      pdf_name: "date_of_birth_mm",
      method: "date_of_birth_mm"
    },
    "abr_date_of_birth_day": {
      pdf_name: "date_of_birth_dd",
      method: "date_of_birth_dd"
    },
    "abr_date_of_birth_year": {
      pdf_name: "date_of_birth_yyyy",
      method: "date_of_birth_yyyy"
    },
    "abr_address_line_1": { method: "address" },
    "abr_city": { method: "city"},
    "abr_home_state_abbrev": { method: "home_state_abbrev"},
    "abr_zip": { method: "zip" },
    "abr_county": {},
    "abr_mailing_street_number": {},
    "abr_mailing_street_name": {},
    "abr_mailing_unit": {},
    "abr_mailing_city": {},
    "abr_mailing_state_abbrev": {},
    "abr_mailing_zip": {},
    "abr_mailing_country": {},
    "abr_id_selections": {
      options: [
        "abr_id_type1",
        "abr_id_type2"
      ]
    },
    "abr_drivers_license": { sensitive: true },
    "abr_id_type2_name": {},
    "abr_election_type_selections": {
      options: [
       "abr_election_type1",
      "abr_election_type2",
      "abr_election_type3",
      "abr_election_type4",
    ]
    },
    "abr_primary_type_selections1": {
      options: [
        "abr_primary_type1",
        "abr_primary_type2",
        "abr_primary_type3"
      ]
    },
    "abr_election_type4_name": {},
  }
  
  EXTRA_FIELDS = ["abr_check_mailing_address"]
   
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Adair",
        "Adams",
        "Allamakee",
        "Appanoose",
        "Audubon",
        "Benton",
        "Black Hawk",
        "Boone",
        "Bremer",
        "Buchanan",
        "Buena Vista",
        "Butler",
        "Calhoun",
        "Carroll",
        "Cass",
        "Cedar",
        "Cerro Gordo",
        "Cherokee",
        "Chickasaw",
        "Clarke",
        "Clay",
        "Clayton",
        "Clinton",
        "Crawford",
        "Dallas",
        "Davis",
        "Decatur",
        "Delaware",
        "Des Moines",
        "Dickinson",
        "Dubuque",
        "Emmet",
        "Fayette",
        "Floyd",
        "Franklin",
        "Fremont",
        "Greene",
        "Grundy",
        "Guthrie",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Harrison",
        "Henry",
        "Howard",
        "Humboldt",
        "Ida",
        "Iowa",
        "Jackson",
        "Jasper",
        "Jefferson",
        "Johnson",
        "Jones",
        "Keokuk",
        "Kossuth",
        "Lee",
        "Linn",
        "Louisa",
        "Lucas",
        "Lyon",
        "Madison",
        "Mahaska",
        "Marion",
        "Marshall",
        "Mills",
        "Mitchell",
        "Monona",
        "Monroe",
        "Montgomery",
        "Muscatine",
        "O'Brien",
        "Osceola",
        "Page",
        "Palo Alto",
        "Plymouth",
        "Pocahontas",
        "Polk",
        "Pottawattamie",
        "Poweshiek",
        "Ringgold",
        "Sac",
        "Scott",
        "Shelby",
        "Sioux",
        "Story",
        "Tama",
        "Taylor",
        "Union",
        "Van Buren",
        "Wapello",
        "Warren",
        "Washington",
        "Wayne",
        "Webster",
        "Winnebago",
        "Winneshiek",
        "Woodbury",
        "Worth",
        "Wright",
      ]}},
    {"abr_check_mailing_address": {type: :checkbox}},
    {"abr_mailing_street_number": {classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
    {"abr_mailing_street_name": {classes: "half", required: :if_visible, visible: "abr_check_mailing_address"}},
    {"abr_mailing_unit": {classes: "quarter", visible: "abr_check_mailing_address"}},
    {"abr_mailing_city": {classes: "half", required: :if_visible, visible: "abr_check_mailing_address"}},
    {"abr_mailing_state_abbrev": {classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address", type: :select, options: GeoState.collection_for_select}},
    {"abr_mailing_zip": {classes: "quarter", required: :if_visible, visible: "abr_check_mailing_address"}},
    {"abr_mailing_country": {visible: "abr_check_mailing_address"}},
    
    {"abr_id_selections": { required: true, type: :radio }},

    {"abr_drivers_license": { required: :if_visible, sensitive: true, visible: "abr_id_selections_abr_id_type1", regexp: /\A[\da-zA-Z]{9}\z/ }},
    {"abr_id_type2_name": {required: :if_visible, visible: "abr_id_selections_abr_id_type2", regexp: /\A\d{4}\z/ }},
    {"abr_election_type_selections": { type: :radio, required: true}},
    {"abr_primary_type_selections1": { type: :radio, required: :if_visible, visible: "abr_election_type_selections_abr_election_type1"}},
    {"abr_election_type4_name": {required: :if_visible, visible: "abr_election_type_selections_abr_election_type4"}},
    
    ]
  end

  
  def custom_form_field_validations
  end
  
 
end