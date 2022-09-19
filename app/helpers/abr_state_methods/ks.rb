module AbrStateMethods::KS
  
  PDF_FIELDS = {
    "abr_email": {method: "email"},	
    "abr_phone": {method: "phone"},	
    "abr_first_name": {method: "first_name"},	
    "abr_middle_initial": {method: "middle_initial"},	
    "abr_last_name": {method: "last_name"},	
    "abr_name_suffix": {method: "name_suffix"},	
    "abr_street_number":{method: "street_number"},
    "abr_street_name":{method:"street_name"},
    "abr_unit":{method:"unit"},
    "abr_city":{method: "city"},
	  "abr_home_state_name": {method: "home_state_abbrev"},	
    "abr_home_state_abbrev": {method: "home_state_abbrev"},	
    "abr_zip": {method: "zip"},	

    'date_of_birth_mm_dd_yyyy':{ method: "date_of_birth_mm_dd_yyyy" },

    'abr_county':{},
    'abr_county2':{method: "abr_county"},

    
    'abr_check_mailing_address':{},
    'abr_mailing_address_line_1':{method: "mailing_address"},
    'abr_mailing_city':{},
    'abr_mailing_state_abbrev':{},
    'abr_mailing_zip':{},
    'abr_id_selections':{
      options:[
        'abr_id_type1',
        'abr_id_type2'
      ]
    },
    'abr_drivers_license':{},

    'abr_party_selections':{
      options: [
      'abr_party1',
      'abr_party2',
      ],
    },
    'step5_date': {method: "abr_election_date"},
    'step5_phone': {method: "phone"},	

    'abr_party1': {method: "abr_party_selection1"},
    'abr_party2': {method: "abr_party_selection2"}

        }

  EXTRA_FIELDS = ["abr_check_mailing_address", "abr_mailing_address_line","abr_mailing_unit",  "abr_election_type_selections"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  def form_field_items
    [
      {"abr_county": {type: :select, required: true, include_blank: true, options: [
        "Allen",
        "Anderson",
        "Atchison",
        "Barber",
        "Barton",
        "Bourbon",
        "Brown",
        "Butler",
        "Chase",
        "Chautauqua",
        "Cherokee",
        "Cheyenne",
        "Clark",
        "Clay",
        "Cloud",
        "Coffey",
        "Comanche",
        "Cowley",
        "Crawford",
        "Decatur",
        "Dickinson",
        "Doniphan",
        "Douglas",
        "Edwards",
        "Elk",
        "Ellis",
        "Ellsworth",
        "Finney",
        "Ford",
        "Franklin",
        "Geary",
        "Gove",
        "Graham",
        "Grant",
        "Gray",
        "Greeley",
        "Greenwood",
        "Hamilton",
        "Harper",
        "Harvey",
        "Haskell",
        "Hodgeman",
        "Jackson",
        "Jefferson",
        "Jewell",
        "Johnson",
        "Kearny",
        "Kingman",
        "Kiowa",
        "Labette",
        "Lane",
        "Leavenworth",
        "Lincoln",
        "Linn",
        "Logan",
        "Lyon",
        "Marion",
        "Marshall",
        "McPherson",
        "Meade",
        "Miami",
        "Mitchell",
        "Montgomery",
        "Morris",
        "Morton",
        "Nemaha",
        "Neosho",
        "Ness",
        "Norton",
        "Osage",
        "Osborne",
        "Ottawa",
        "Pawnee",
        "Phillips",
        "Pottawatomie",
        "Pratt",
        "Rawlins",
        "Reno",
        "Republic",
        "Rice",
        "Riley",
        "Rooks",
        "Rush",
        "Russell",
        "Saline",
        "Scott",
        "Sedgwick",
        "Seward",
        "Shawnee",
        "Sheridan",
        "Sherman",
        "Smith",
        "Stafford",
        "Stanton",
        "Stevens",
        "Sumner",
        "Thomas",
        "Trego",
        "Wabaunsee",
        "Wallace",
        "Washington",
        "Wichita",
        "Wilson",
        "Woodson",
        "Wyandotte",
      ]}},


	
      {"abr_check_mailing_address": {type: :checkbox}},	
      
      {"abr_mailing_address_instructions": {type: :instructions,  visible: "abr_check_mailing_address"}},
      {"abr_mailing_address_line": {classes: 'three-quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_unit": {classes: 'quarter', required: false, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_city": {classes: 'half', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_state_abbrev": {type: :select, options: GeoState.collection_for_select, classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	
      {"abr_mailing_zip": {classes: 'quarter', required: :if_visible, visible: "abr_check_mailing_address"}},	

      {"abr_id_selections": {type: :radio, options: ["abr_id_type1", "abr_id_type2"]}},
      {"abr_drivers_license": {visible: "abr_id_selections_abr_id_type1", required: "show_star", min: 9, max: 9, ui_regexp:"^[kK][0-9]{8}$"}},
      {"abr_id_type2_instructions": {type: :instructions, visible:"abr_id_selections_abr_id_type2" }},
     {"abr_election_type_selections": {type: :radio, options: ["abr_election_type2"]}},
      # {"abr_party_selections": {visible: "abr_election_type_selections_abr_election_type1", type: :radio, options: ["abr_party1", "abr_party2"]}},
      

    ]
  end

  def abr_election_type_selections
    return("abr_election_type2")
  end
  
  def abr_election_date
    v = self.abr_election_type_selections
    return "August 2, 2022" if v == "abr_election_type1"
    return "November 8, 2022" if v == "abr_election_type2"

  end

  # def abr_party_selection1 
  #   v = self.abr_party_selections
  #   return "Off" if v.blank?
  #   return ( v == "abr_party1" ? "On" : "Off")
  # end

  # def abr_party_selection2 
  #   v = self.abr_party_selections
  #   return "Off" if v.blank?
  #   return ( v == "abr_party2" ? "On" : "Off")
  # end

  def mailing_address
    "#{abr_mailing_address_line}" + (abr_mailing_unit.blank? ? '' : ", #{abr_mailing_unit}")
  end

  def custom_form_field_validations

  end
  
 
end
