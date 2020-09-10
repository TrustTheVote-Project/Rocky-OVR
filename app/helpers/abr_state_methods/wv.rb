module AbrStateMethods::WV
  
  PDF_FIELDS = {
    "Suffix": {
      method: "name_suffix"
    },
    "Date of Birth": {
      method: "date_of_birth_mm"
    },
    "undefined": {
      method: "date_of_birth_dd"
    },
    "undefined_2": {
      method: "date_of_birth_yyyy"
    },
    "Lastname": {
      method: "last_name"
    },
    "Firstname": {
      method: "first_name"
    },
    "Middlename": {
      method: "middle_name"
    },
    "resident_county": {},
    "resident_city": {
      method: "city"
    },
    "resident_zip": {
      method: "zip"
    },
    "resident_street": {
      method: "address"
    },
    "mail_address": {},
    "mail_city": {},
    "mail_state": {},
    "mail_zip": {},
    "phone": {
      method: "phone"
    },
    "reason": { options: ["address_confidentiality", "business_or_travel", "college", "disability", "elected_away", "employment", "illness", "immobility", "working_away", "disability_want_electronic", "incarceration"] },
    "email": {
      method: "reason_disab_electronic" #TODO - see below
    },
    "which_election": { 
      options: ["Off", "city_town", "federal_state_county"],
      value:  "federal_state_county"
    },
    "election_type": { 
      options: ["Off", "general", "primary", "special"],
      value: "general" 
    },
    "request_party": { 
      options: ["Democrat", "Mountain", "Off", "Republican"],
      value: "Off" 
    },
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  # def reason_disab_electronic
  #   # TODO when "reason_disability_want_electronic" is selected, it should autofill with "email" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"resident_county": {type: :select, required: true, include_blank: true, options: [
        "Barbour",
        "Berkeley",
        "Boone",
        "Braxton",
        "Brooke",
        "Cabell",
        "Calhoun",
        "Clay",
        "Doddridge",
        "Fayette",
        "Gilmer",
        "Grant",
        "Greenbrier",
        "Hampshire",
        "Hancock",
        "Hardy",
        "Harrison",
        "Jackson",
        "Jefferson",
        "Kanawha",
        "Lewis",
        "Lincoln",
        "Logan",
        "McDowell",
        "Marion",
        "Marshall",
        "Mason",
        "Mercer",
        "Mineral",
        "Mingo",
        "Monongalia",
        "Monroe",
        "Morgan",
        "Nicholas",
        "Ohio",
        "Pendleton",
        "Pleasants",
        "Pocahontas",
        "Preston",
        "Putnam",
        "Raleigh",
        "Randolph",
        "Ritchie",
        "Roane",
        "Summers",
        "Taylor",
        "Tucker",
        "Tyler",
        "Upshur",
        "Wayne",
        "Webster",
        "Wetzel",
        "Wirt",
        "Wood",
        "Wyoming",
      ]}},
      {"reason": {type: :radio, required: true}}, #TODO - change format to match form
      {"incarceration_statement": {visible: "reason_incarceration", type: :instructions, classes: "indent"}},
      {"has_mailing_address": {type: :checkbox}},
      {"mail_address": {visible: "has_mailing_address"}},
      {"mail_city": {visible: "has_mailing_address", classes: "half"}},
      {"mail_state": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"mail_zip": {visible: "has_mailing_address", classes: "quarter last"}},
    ]
  end
  
  def custom_form_field_validations
    # e.g:
    # make sure delivery is selected if reason ==3
    # e.g:
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end