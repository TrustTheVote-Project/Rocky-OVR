module AbrStateMethods::NY
  
  PDF_FIELDS = {
    "date of birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "suffix": {
      method: "name_suffix"
    },
    "middle initial": {
      method: "middle_initial"
    },
    "first name": {
      method: "first_name"
    },
    "last name or surname": {
      method: "last_name"
    },
    "phone number (optional)": {
      method: "phone"
    },
    "email (optional)": {
      method: "email"
    },
    "county where you live": {},
    "street (Residence)": {
      method: "address_line_1"
    },
    "city (Residence)": {
      method: "city"
    },
    "zip code (Residence)": {
      method: "zip"
    },
    #Date (Applicant Signed)
    # "(address of witness to mark)": {},
    # "Name of Voter:": {
    #   method: "full_name"
    # },
    #(signature of witness to mark)
    #Date (Applicant Marked)
    #Mark: (Applicant mark in lieu of signature)
    "street number (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_street_number"
    },
    "street name (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_street_name"
    },
    "apartment (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_unit"
    },
    "city (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_city"
    },
    "state (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_home_state_abbrev"
    },
    "zip code (General (or Special) Election Ballot Mailing Address)":{ 
      method:"override_zip"
    },
    "I authorize (give name): (blank space) to pick up my General (or Special) Election Ballot at the board of elections": {},
    "apartment (Residence)": {
      method: "unit"
    },
    "reason": {
      options: ["absence_from_country", "detention", "permanent_illness", "primary_care", "temporary_illness", "va_resident"]
    },
    "election": {
      options: ["any", "general", "primary", "special"],
      value: "general"
    },
    "deliver_general_ballot": {
      options: ["general_in_person", "general_mail", "general_to_proxy"]
    },
    #"voter_signature"
  }
  EXTRA_FIELDS = ["has_mailing_address", "witness", "mail_street_number", "mail_street_name", "mail_unit", "mail_city", "mail_state", "mail_zip"]
  
  
  def form_field_items
    [
      {"county where you live": {type: :select, required: true, include_blank: true, options: [
        "Albany",
        "Allegany",
        "Bronx",
        "Broome",
        "Cattaraugus",
        "Cayuga",
        "Chautauqua",
        "Chemung",
        "Chenango",
        "Clinton",
        "Columbia",
        "Cortland",
        "Delaware",
        "Dutchess",
        "Erie",
        "Essex",
        "Franklin",
        "Fulton",
        "Genesee",
        "Greene",
        "Hamilton",
        "Herkimer",
        "Jefferson",
        "Kings",
        "Lewis",
        "Livingston",
        "Madison",
        "Monroe",
        "Montgomery",
        "Nassau",
        "New York City",
        "Niagara",
        "Oneida",
        "Onondaga",
        "Ontario",
        "Orange",
        "Orleans",
        "Oswego",
        "Otsego",
        "Putnam",
        "Queens",
        "Rensselaer",
        "Richmond",
        "Rockland",
        "St. Lawrence",
        "Saratoga",
        "Schenectady",
        "Schoharie",
        "Schuyler",
        "Seneca",
        "Steuben",
        "Suffolk",
        "Sullivan",
        "Tioga",
        "Tompkins",
        "Ulster",
        "Warren",
        "Washington",
        "Wayne",
        "Westchester",
        "Wyoming",
        "Yates",
      ]}},
      {"reason": {type: :radio, required: true}},
      {"deliver_general_ballot": {type: :radio, required: true}},
      {"I authorize (give name): (blank space) to pick up my General (or Special) Election Ballot at the board of elections": {visible: "deliver_general_ballot_general_to_proxy", required: "star"}}, # :is_visible throws err
      {"has_mailing_address": {type: :checkbox}},
      # TODO mailing address only applies when "deliver_general_ballot" == "general_mail". checkbox should be hidden when "general_mail" not selected and "mail_*" fields should not be populated.
      {"mail_street_number": {visible: "has_mailing_address",required: "star", classes: "quarter"}},
      {"mail_street_name": {visible: "has_mailing_address",required:"star", classes: "half"}},
      {"mail_unit": {visible: "has_mailing_address", classes: "quarter last"}},
      {"mail_city": {visible: "has_mailing_address", required: "star", classes: "half"}},
      {"mail_state": {visible: "has_mailing_address", required: "star", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"mail_zip": {visible: "has_mailing_address",required:"star", classes: "quarter last"}},
      {"witness": {type: :checkbox}},
      {"(address of witness to mark)": {visible: "witness"}},
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
  

  def override_field_value(override, fieldname1, fieldname2) 
    if (override) 
      #return self.send("#{self.class.make_method_name(fieldname2)}") 
      return self.send(fieldname2) 
    else 
      #return self.send("#{self.class.make_method_name(fieldname1)}")
      return self.send(fieldname1)
    end
  end

  def override_mailing_address_field (fieldname1, fieldname2)
      return override_field_value((self.has_mailing_address.to_s == "1"), fieldname1, fieldname2)
  end

  def override_street_number
    return override_mailing_address_field("street_number", "mail_street_number")
  end 
  
  def override_street_name
    return override_mailing_address_field("street_name", "mail_street_name")
  end

  def override_unit
    return override_mailing_address_field("unit", "mail_unit")
  end

  def override_city
    return override_mailing_address_field("city", "mail_city")
  end

  def override_home_state_abbrev
    return override_mailing_address_field("home_state_abbrev", "mail_state")
  end 

  def override_zip
    return override_mailing_address_field("zip", "mail_zip")
  end
  
  REQUIRED_MAILING_ADDRESS_FIELDS = [
    "mail_street_number",
    "mail_street_name",
    #"apartment (General (or Special) Election Ballot Mailing Address)",
    "mail_city",
    "mail_state",
    "mail_zip"
  ]

  def require_mailing_fields
    REQUIRED_MAILING_ADDRESS_FIELDS.each do |field|
      custom_validates_presence_of(field)
    end
  end

  def custom_form_field_validations  
    #if mailing address different, require it
    if self.has_mailing_address.to_s == "1"
      require_mailing_fields
    end

    #if deliver by proxy, require proxy
    if self.deliver_general_ballot == "general_to_proxy"
      custom_validates_presence_of("I authorize (give name): (blank space) to pick up my General (or Special) Election Ballot at the board of elections")
    end
    
  end


 
end