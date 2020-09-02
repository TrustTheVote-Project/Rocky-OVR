module AbrStateMethods::TX
  
  PDF_FIELDS = {
      "Suffix": {
        method: "name_suffix"
      },
      "First Name": {
        method: "first_name"
      },
      "Middle Initial": { method: "middle_initial" },
      "Residence_Address": {
        method: "address"
      },
      "City TX": {
        method: "city"
      },
      "ZIP Code": {
        method: "zip"
      },
      "Mail_Address": {},
      "State": {},
      "ZIP Code_2": {},
      "Contact_Info": {
        method: "phone_and_email" 
      },
      "DoB_mm": { method: "date_of_birth_mm" }, #month only - max: 2
      "Annual Application": {
        options: ["Off", "Yes"],
        value: "Off"
      },
      "Republican Primary": {
        options: ["Off", "Republican Primary"],
        value: "Off"
      },
      "witness": { options: ["Off", "Yes"] },
      "Assisted": { options: ["Off", "Yes"] },
      "Witness_relation": {},
      "DoB_dd": { method: "date_of_birth_dd" }, #day only - max: 2
      "Dob_yyyy": {  method: "date_of_birth_yyyy" }, #year only - max: 4
      "absence_from_mm": {},
      "absence_from_dd": {},
      "absence_from_yyyy": {},
      "absence_to_mm": {},
      "absence_to_dd": {},
      "absencs_to_yyyy": {},
      "Reason": { options: ["absence", "age", "confinement", "disability"] },
      "where_to_mail": {
        options: ["hospital", "jail", "mailing_address", "nursing_home", "outside_county", "relative", "retirement_center"]
      },
      #Date of signature
      "City of witness": {},
      "Zip code of witness": {},
      "State of witness": {},
      "Street address of witness": {},
      "Apt number of witness": {},
      "which_election": {
        method: "november_election_if_over_65",
        options: ["Any resulting runoff", "May_election", "November_election", "Off", "Other", "annual_application"] 
      },
      "which_election2": { 
        method: "november_election_if_confined_to_jail",
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
      "Mailing City": {
        pdf_name: "City"
      },
      "Early voting clerk's address": {}, #only needed if applicant wants to email their PDF application
    }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def november_election_if_over_65
    if self.send(self.class.make_method_name("Reason")) == "age"
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
  
  
  
  def form_field_items
    [
      {"Reason": {required: true, type: :radio}}, 
      {"absent_from": {classes: 'half', visible: "reason_absence", type: :date, d: "absence_from_dd", m: "absence_from_mm", y: "absence_from_yyyy" }},
      {"absent_to": {classes: 'half last', visible: "reason_absence", type: :date, d: "absence_to_dd", m: "absence_to_mm", y: "absencs_to_yyyy" }},
      {"has_mailing_address": {type: :checkbox}},
      {"Mail_Address": {visible: "has_mailing_address"}},
      {"Mailing City": {visible: "has_mailing_address", classes: "half"}},
      {"State": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP Code_2": {visible: "has_mailing_address", classes: "quarter last", min: 5, max: 10}},
      {"where_to_mail": {
        visible: "has_mailing_address", type: :radio}}, 
      {"relative_relationship": {visible: "where_to_mail_relative"}},
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
  
  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      ["Mail_Address", "City", "State", "ZIP Code_2"].each do |f|
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
    
    if self.send(self.class.make_method_name("where_to_mail")) == "relative"
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