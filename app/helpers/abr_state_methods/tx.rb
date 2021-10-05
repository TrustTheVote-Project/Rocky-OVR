module AbrStateMethods::TX
  
  PDF_FIELDS = {
      "Suffix": {
        method: "name_suffix"
      },
      "First Name": {
        method: "first_name"
      },
      "Middle name": { method: "middle_name" },
      "Address": {
        method: "address"
      },
      "City": {
        method: "city"
      },
      "Zip Code": {
        method: "zip"
      },
      "State": { method: "home_state_abbrev"},
      
      "Apt": {
        method: "unit"
      },

      "mail_to_residence": {
        options: ["Off", "Yes"],
        method: "yes_if_no_mailing_address"
      },
      "mail_to_other": {
        options: ["Off", "Yes"],
        method: "yes_if_has_mailing_address"
      },
      
      "Address_2": {},
      "Apt if any 2": {},
      "City 2": {
      },
      "State 2": { },
      
      
      "Zip Code 2": {},
      "Phone": {
        method: "phone"
      },
      "Email": {
        method: "email" 
      },
      "Annual Application": {
        options: ["Off", "Yes"],
        value: "Off"
      },
      "Republican Primary": {
        options: ["Off", "Republican Primary"],
        value: "Off"
      },
      
      
      "DoB_mm": { method: "date_of_birth_mm" }, #month only - max: 2
      "DoB_dd": { method: "date_of_birth_dd" }, #day only - max: 2
      "DoB_yyyy": {  method: "date_of_birth_yyyy" }, #year only - max: 4
      

      "absence_from_mm": {},
      "absence_from_dd": {},
      "absence_from_yyyy": {},
      "absence_to_mm": {},
      "absence_to_dd": {},
      "absencs_to_yyyy": {},
      "Reason": { options: ["absence", "age", "confinement", "disability", "maternity"] },
      "where_to_mail": {
        method: "where_to_mail_consolidated",
        options: ["hospital", "jail", "mailing_address", "outside_county"]
      },


      "witness": { options: ["Off", "Yes"] },
      "Assisted": { options: ["Off", "Yes"] },
      "Witness_relation": {},




      #Date of signature
      "City of witness": {},
      "Zip code of witness": {},
      "State of witness": {},
      "Street address of witness": {},
      "Apt number of witness": {},
      "which_election": {
        #method: "november_election_if_over_65",
        method: "any_resulting_runoff_if_over_65",
        options: ["Yes", "Off"] 
      },
      "which_election2": { 
        #method: "november_election_if_confined_to_jail",
        method: "any_resulting_runoff_if_confined_to_jail",        
        options: ["Any resulting runoff", "May_election", "November_election", "Off", "Other"] 
      },
      "name": {
        method: "full_name" #return address
      },
      "address": {
        method: "address" #return address
      },
      "city and state": { method: "address_city_state_zip" }, #return address: city, state zip
      "To: Early Voting Clerk's address": {}, #TODO registrar address nearest voting clerk based on the location they entered?
      "To: Early Voting Clerk's state": {}, #TODO registrar city, state zip
      "Last Name": {
        method: "last_name"
      },
      "relative_relationship": {}, #this is the text field for the radio option
      "early voting clerks fax": {}, #only needed if applicant wants to fax their PDF application
      "Early voting clerk's address": {}, #only needed if applicant wants to email their PDF application
    }
  EXTRA_FIELDS = ["has_mailing_address", "where_to_mail_all"]
  
  def yes_if_no_mailing_address
    if self.has_mailing_address == "0"
      return "Yes"
    else
      return "Off"
    end
  end

  def yes_if_has_mailing_address
    if self.has_mailing_address == "1"
      return "Yes"
    else
      return "Off"
    end
  end

  def november_election_if_over_65
    if self.send(self.class.make_method_name("Reason")) == "age" || self.send(self.class.make_method_name("Reason")) == "disability"
      "November_election" 
    else
      "Off"
    end
  end
  
  def november_election_if_confined_to_jail
    if self.send(self.class.make_method_name("Reason")) == "confinement" || self.send(self.class.make_method_name("Reason")) == "absence"
      "November_election" 
    else
      "Off"
    end
  end

  def any_resulting_runoff_if_over_65
    if self.send(self.class.make_method_name("Reason")) == "age" || self.send(self.class.make_method_name("Reason")) == "disability"
      "On" 
    else
      "Off"
    end
  end
  
  def any_resulting_runoff_if_confined_to_jail
    if self.send(self.class.make_method_name("Reason")) == "confinement" || self.send(self.class.make_method_name("Reason")) == "absence"
      "Any resulting runoff" 
    else
      "Off"
    end
  end
  
  
  
  def form_field_items
    [
      {"Reason": {required: true, type: :radio}}, 
      {"absent_from": {classes: 'half', visible: "reason_absence", type: :date, d: "absence_from_dd", m: "absence_from_mm", y: "absence_from_yyyy" }},
      {"absent_to": {classes: 'half last', visible: "reason_absence", type: :date, d: "absence_to_dd", m: "absence_to_mm", y: "absencs_to_yyyy" }},
      {"has_mailing_address": {type: :checkbox}},
      {"Address_2": {visible: "has_mailing_address", classes: "three-quarter"}},
      {"Apt if any 2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"City 2": {visible: "has_mailing_address", classes: "half"}},
      {"State 2": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Zip Code 2": {visible: "has_mailing_address", classes: "quarter last", min: 5, max: 10}},
      {"where_to_mail_all": {
        required: :if_visible,
        visible: "has_mailing_address", type: :radio, options: ["mailing_address", "outside_county", "relative", "hospital", "jail"]}}, 
      {"relative_relationship": {visible: "where_to_mail_all_relative"}},
      {"witness": {
        type: :checkbox}}, 
      {"Assisted": {
        visible: "witness", 
        type: :checkbox}},
      {"Witness_relation": {
        visible: "witness"}},
        #witness' relationship to applicant
      {"Street address of witness": {
        classes: "three-quarter",
        visible: "witness"}}, 
      {"Apt number of witness": {
        classes: "quarter last",
        visible: "witness"}}, 
      {"City of witness": {
        classes: "half",
        visible: "witness"}},
      {"State of witness": {
        classes: "quarter",
        visible: "witness",
        type: :select, options: GeoState.collection_for_select, include_blank: true}}, 
      {"Zip code of witness": {
        classes: "quarter last",
        visible: "witness"}},
    ]
  end
  
  def where_to_mail_consolidated
    val = self.send(self.class.make_method_name("where_to_mail_all")) 
    if val == "relative"
      return "hospital"
    end
    return val
  end

  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      ["Address 2", "City 2", "State 2", "Zip Code 2"].each do |f|
        custom_validates_presence_of(f)
        #errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
      end
    end
    if self.reason == "absence" && self.has_mailing_address != "1"
      errors.add(:has_mailing_address, "You must provide a mailing address outside of your residece county")
    end
    if self.reason == "confinement" && self.has_mailing_address != "1"
      errors.add(:has_mailing_address, "You must provide a mailing address")
    end
    
    if self.send(self.class.make_method_name("where_to_mail_all")) == "relative"
      custom_validates_presence_of("relative_relationship")
    end
    if self.send("witness") == "1"
      ["Witness_relation",
      "Street address of witness",
      "City of witness",
      "State of witness",
      "Zip code of witness"].each do |f|
        custom_validates_presence_of(f)
      end
    end
  end

  
end