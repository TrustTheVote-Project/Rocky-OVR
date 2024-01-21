module AbrStateMethods::OH
  
  PDF_FIELDS = {
    "abr_first_name": {	method: "first_name" },
    "abr_last_name": {	method: "last_name" },
    "abr_middle_name": {	method: "middle_name" },
    "abr_name_suffix": {	method: "name_suffix" },
    "abr_phone": {	method: "phone" },
    "abr_email": {	method: "email" },
    "abr_date_of_birth_complete": {	method: "date_of_birth_mm_dd_yyyy" },
    "abr_address_line_1": {	method: "address" },
    "abr_city": {	method: "city" },
    "abr_county": {	 },
    "abr_home_state_abbrev": {	method: "home_state_abbrev" },
    "abr_zip": {	method: "zip" },
    "abr_id_type": {	options: ["abr_id_type1", "abr_id_type2", "abr_no_id"] },
    "abr_last_4_ssn": {	sensitive: true },
    "abr_drivers_license": { sensitive: true },
    "abr_election_type_selections": {	options: ["abr_election_type1", "abr_election_type2", "abr_election_type3"] },
    "abr_primary_type_selections": { 	options: ["abr_primary_type1", "abr_primary_type2", "abr_primary_type3"] },
    "abr_election_date": {
      method: "abr_election_date_string"
    },
    "abr_election_date2": {
      method: "abr_election_date2_string"      
    },
    #"abr_check_mailing_address": { },
    "abr_mailing_address_instructions": {	 },
    "abr_mailing_street_address": {	 },
    "abr_mailing_city": {	},
    "abr_mailing_state_abbrev": {  },
    "abr_mailing_zip": { },
  }
  
  EXTRA_FIELDS = ["abr_check_mailing_address", 
    "abr_election_date_input_mm", "abr_election_date_input_dd", "abr_election_date_input_yyyy",
    "abr_election_date2_input_mm", "abr_election_date2_input_dd", "abr_election_date2_input_yyyy"]

  
  def form_field_items
    [
      # from https://www.alphalists.com/list/alphabetical-list-ohio-counties
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Adams",
        "Allen",
        "Ashland",
        "Ashtabula",
        "Athens",
        "Auglaize",
        "Belmont",
        "Brown",
        "Butler",
        "Carroll",
        "Champaign",
        "Clark",
        "Clermont",
        "Clinton",
        "Columbiana",
        "Coshocton",
        "Crawford",
        "Cuyahoga",
        "Darke",
        "Defiance",
        "Delaware",
        "Erie",
        "Fairfield",
        "Fayette",
        "Franklin",
        "Fulton",
        "Gallia",
        "Geauga",
        "Greene",
        "Guernsey",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Harrison",
        "Henry",
        "Highland",
        "Hocking",
        "Holmes",
        "Huron",
        "Jackson",
        "Jefferson",
        "Knox",
        "Lake",
        "Lawrence",
        "Licking",
        "Logan",
        "Lorain",
        "Lucas",
        "Madison",
        "Mahoning",
        "Marion",
        "Medina",
        "Meigs",
        "Mercer",
        "Miami",
        "Monroe",
        "Montgomery",
        "Morgan",
        "Morrow",
        "Muskingum",
        "Noble",
        "Ottawa",
        "Paulding",
        "Perry",
        "Pickaway",
        "Pike",
        "Portage",
        "Preble",
        "Putnam",
        "Richland",
        "Ross",
        "Sandusky",
        "Scioto",
        "Seneca",
        "Shelby",
        "Stark",
        "Summit",
        "Trumbull",
        "Tuscarawas",
        "Union",
        "Van Wert",
        "Vinton",
        "Warren",
        "Washington",
        "Wayne",
        "Williams",
        "Wood",
        "Wyandot",
      ]}},
      {"abr_check_mailing_address": {type: :checkbox}},
      {"abr_mailing_address_instructions": { type: :instructions, visible: "abr_check_mailing_address" }},
      {"abr_mailing_street_address": {visible: "abr_check_mailing_address", required: :if_visible}},
      {"abr_mailing_city": {classes: "half", visible: "abr_check_mailing_address", required: :if_visible}},
      {"abr_mailing_state_abbrev": {classes: "quarter", visible: "abr_check_mailing_address", required: :if_visible, type: :select, options: GeoState.collection_for_select}},
      {"abr_mailing_zip": {classes: "quarter", visible: "abr_check_mailing_address", required: :if_visible, min: 5, max: 10}},

      {"abr_id_type": {type: :radio, required: true}},
      {"abr_last_4_ssn": {visible: "abr_id_type_abr_id_type1", required: "show_star",  min: 4, max: 4, regexp: /\A\d{4}\z/ }},
      {"abr_drivers_license": {visible: "abr_id_type_abr_id_type2", required: "show_star", min: 8, max: 8, regexp: /\A[a-zA-Z]{2}[0-9]{6}\z/, ui_regexp: "^[a-zA-Z]{2}[0-9]{6}$"}},
      {"abr_election_type_selections": {type: :radio, required: true}},
      {"abr_election_date_input": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type2"}},
      #{"abr_election_date2_input": {type: :date, required: :if_visible, visible: "abr_election_type_selections_abr_election_type3"}},
      {"abr_primary_type_selections": {type: :radio, required: :if_visible, visible: "abr_election_type_selections_abr_election_type3"}},

    ]
  end

  def abr_election_date_string
    date_field_string_mm_dd_yyyy(method: :abr_election_date_input)
  end
  
  def abr_election_date2_string
    if abr_election_type_selections_abr_election_type3
      #return "August 2, 2022"
      return ""
    end
    #date_field_string_mm_dd_yyyy(method: :abr_election_date2_input)
  end

  # def custom_form_field_validations
  #   if self.has_mailing_address.to_s == "1"
  #     ["Street Address or PO Box", "City_2", "State", "ZIP_2"].each do |f|
  #       custom_validates_presence_of(f)
  #     end
  #   end
  #   if self.identification == "dln"
  #     custom_validates_presence_of("Ohio_driver_license")
  #   end
  #   if self.identification == "ssn4"
  #     custom_validates_presence_of("SSN4")
  #   end
  # end

end