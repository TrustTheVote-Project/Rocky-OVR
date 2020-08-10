module AbrStateMethods::GA
  
  PDF_FIELDS = {
    "Text6": {
      method: "middle_name"
    },
    "Text7": {
      method: "last_name"
    },
    "Text8": {
      method: "name_suffix"
    },
    "Text9": {
      method: "address"
    },
    "Text10": {
      method: "city"
    },
    "Text11": {
      method: "zip"
    },
    "Text12": {}, #residence county
    "Text13": {}, #mailing street
    "Text14": {}, #mailing city
    "Text15": {}, #mailing zip
    "Text16": {}, #mailing county
    "Text17": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Text18": {
      method: "phone"
    },
    "Text19": {
      method: "email"
    },
    "Text21": {}, #today's date
    "Text23": {}, #today's date assistant
    "Text25": {}, #requestor's relationship to voter
    "Text26": {
      method: "email" #only required if "Elegibility_U" is checked
    },
    "Text5": {
      method: "first_name"
    },
    #voter_signature
    "Election_Date": {
      value: "11/03/2020"
    },
    "address_has_changed": {
      options: ["Off", "Yes"]
    },
    "type_of_ballot": {
      options: ["Democratic", "Non_Partisan", "Off", "Republican"]
    },
    "reason_other": {
      options: ["Off", "disabled", "out_of_country"]
    },
    "Elegibility": {
      options: ["D", "E", "Off", "U"]
    },
    "UOCAVA_Status": {
      options: ["MOS", "MST", "OSP", "OST", "Off"]
    }
  }
 
  EXTRA_FIELDS = ["has_mailing_address", "assisted_voter", "requestor"] 
  
  def form_field_items
    [
      {"type_of_ballot": {type: :radio, options: []}}, #TODO- grab options from above
      {"Text12": {type: :select, required: true, include_blank: true, options: [
        "Appling",
        "Atkinson",
        "Bacon",
        "Baker",
        "Baldwin",
        "Banks",
        "Barrow",
        "Bartow",
        "Ben Hill",
        "Berrien",
        "Bibb",
        "Bleckley",
        "Brantley",
        "Brooks",
        "Bryan",
        "Bulloch",
        "Burke",
        "Butts",
        "Calhoun",
        "Camden",
        "Candler",
        "Carroll",
        "Catoosa",
        "Charlton",
        "Chatham",
        "Chattahoochee",
        "Chattooga",
        "Cherokee",
        "Clarke",
        "Clay",
        "Clayton",
        "Clinch",
        "Cobb",
        "Coffee",
        "Colquitt",
        "Columbia",
        "Cook",
        "Coweta",
        "Crawford",
        "Crisp",
        "Dade",
        "Dawson",
        "De Kalb",
        "Decatur",
        "Dodge",
        "Dooly",
        "Dougherty",
        "Douglas",
        "Early",
        "Echols",
        "Effingham",
        "Elbert",
        "Emanuel",
        "Evans",
        "Fannin",
        "Fayette",
        "Floyd",
        "Forsyth",
        "Franklin",
        "Fulton",
        "Gilmer",
        "Glascock",
        "Glynn",
        "Gordon",
        "Grady",
        "Greene",
        "Gwinnett",
        "Habersham",
        "Hall",
        "Hancock",
        "Haralson",
        "Harris",
        "Hart",
        "Heard",
        "Henry",
        "Houston",
        "Irwin",
        "Jackson",
        "Jasper",
        "Jeff Davis",
        "Jefferson",
        "Jenkins",
        "Johnson",
        "Jones",
        "Lamar",
        "Lanier",
        "Laurens",
        "Lee",
        "Liberty",
        "Lincoln",
        "Long",
        "Lowndes",
        "Lumpkin",
        "Macon",
        "Madison",
        "Marion",
        "McDuffie",
        "McIntosh",
        "Meriwether",
        "Miller",
        "Mitchell",
        "Monroe",
        "Montgomery",
        "Morgan",
        "Murray",
        "Muscogee",
        "Newton",
        "Oconee",
        "Oglethorpe",
        "Paulding",
        "Peach",
        "Pickens",
        "Pierce",
        "Pike",
        "Polk",
        "Pulaski",
        "Putnam",
        "Quitman",
        "Rabun",
        "Randolph",
        "Richmond",
        "Rockdale",
        "Schley",
        "Screven",
        "Seminole",
        "Spalding",
        "Stephens",
        "Stewart",
        "Sumter",
        "Talbot",
        "Taliaferro",
        "Tattnall",
        "Taylor",
        "Telfair",
        "Terrell",
        "Thomas",
        "Tift",
        "Toombs",
        "Towns",
        "Treutlen",
        "Troup",
        "Turner",
        "Twiggs",
        "Union",
        "Upson",
        "Walker",
        "Walton",
        "Ware",
        "Warren",
        "Washington",
        "Wayne",
        "Webster",
        "Wheeler",
        "White",
        "Whitfield",
        "Wilcox",
        "Wilkes",
        "Wilkinson",
        "Worth",
      ]}},
      {"has_mailing_address": {type: :checkbox}},
      {"Text13": {visible: "has_mailing_address"}},
      {"Text14": {visible: "has_mailing_address"}},
      {"Text15": {visible: "has_mailing_address", min: 5, max: 10}},
      {"Text16": {visible: "has_mailing_address"}},
      {"address_has_changed": {type: :checkbox, visible: "has_mailing_address"}},
      {"assisted_voter": {type: :checkbox}},
      {"Text23": {visible: "assisted_voter"}},
      {"requestor": {type: :checkbox}},
      {"Text25": {visible: "requestor"}},
      {"reason_other": {visible: "requestor", type: :radio, options: ["disabled", "out_of_country"]}},
      #{"Elegibility": {type: :radio, options: []}}, #TODO- grab options from above
      #{"UOCAVA_Status": {visible: "Elegibility_U", type: :radio, options: []}}, #TODO- grab options from above
    ]
  end
  #e.g.
  # [
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
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end