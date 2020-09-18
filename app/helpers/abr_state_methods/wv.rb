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
      "reason": { 
          method: "reason_a_or_b"
        },
      "email": {
        method: "reason_disab_electronic" #TODO - see below #TODONE
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
    EXTRA_FIELDS = ["has_mailing_address", "reason_meta", "reason_a"]
    
    def reason_disab_electronic
    #   # TODO when "reason_disability_want_electronic" is selected, it should autofill with "email" and otherwise left blank
        return self.email if self.reason_meta.to_s=='B'
    end
    
    def state_registrar_address
      if self.reason_a == "address_confidentiality"
        @state_registrar_address ||= home_state && home_state.state_registrar_address
      else
        @state_registrar_address ||= home_state && home_state.abr_address(self.zip)
      end
    end
  
    def delivery_full_address
      addr = self.reason_a == "address_confidentiality" ? home_state&.state_registrar_address : state_registrar_office&.req_address
      return addr.blank? ? state_registrar_office&.address : addr
    end
    
  
    
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
        {'reason_meta': {type: :radio, required: true, options: ["A", "B"]}},
        {"reason_a": {type: :radio, visible: "reason_meta_a", required: 'star', options: ["address_confidentiality", "business_or_travel", "college", "disability", "elected_away", "employment", "illness", "immobility", "working_away", "incarceration"]}}, #TODO - change format to match form #To Done
        {"incarceration_statement": {visible: "reason_incarceration", type: :instructions, classes: "indent"}},
        {"has_mailing_address": {type: :checkbox}},
        {"mail_address": {visible: "has_mailing_address", required: :if_visible}},
        {"mail_city": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
        {"mail_state": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
        {"mail_zip": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last"}},
      ]
    end

    def reason_a_or_b
        return (reason_meta.to_s=='A' ? reason_a.to_s : 'disability_want_electronic')
    end
    
    MAILING_ADDRESS_REQUIRED_REASONS = ["business_or_travel" , "college","elected_away" , "working_away"]

    def custom_form_field_validations
      # e.g:
      # make sure delivery is selected if reason ==3
      # e.g:
      # make sure fax is provided if faxtype is selected for delivery
      if self.reason_meta.to_s=='A'
        custom_validates_presence_of ('reason_a')
      end

      
      if  MAILING_ADDRESS_REQUIRED_REASONS.include?(self.reason_a.to_s) && self.has_mailing_address.to_s!='1'
        errors.add('has_mailing_address',custom_required_message("has_mailing_address"))
      end

    end
    
   
  end
  