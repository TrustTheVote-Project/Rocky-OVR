module AbrStateMethods::TX
  
  PDF_FIELDS = {
      "Suffix Jr Sr III etc": {
        method: "name_suffix"
      },
      "First Name": {
        method: "first_name"
      },
      "Middle Initial": { method: "middle_initial" },
      "2 Residence Address See back of this application for instructions": {
        method: "address"
      },
      "City TX": {
        method: "city"
      },
      "ZIP Code": {
        method: "zip"
      },
      "3 Mail my ballot to If mailing address differs from residence address please complete Box  7": {},
      "State": {},
      "ZIP Code_2": {},
      "4 Date of Birth mmddyyyy Optional Contact Information Optional Please list phone number andor email address  Used in case our office has questions": {
        method: "phone_and_email" 
      },
      "Date of Birth mmddyyyy Optional": { method: "date_of_birth_mm" }, #month only - max: 2
      "Annual Application": {
        options: ["Off", "Yes"],
        value: "Off"
      },
      "Republican Primary": {
        options: ["Off", "Republican Primary"],
        value: "Off"
      },
      "If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below": {},
      "If you assisted the applicant in completing this application in the applicants presence or emailedmailed or faxed the application on behalf of the applicant please check this box as an Assistant and sign below": {},
      "Refer to Instructions on back for clarification": {},
      "Optional: Day of date of birth": { method: "date_of_birth_dd" }, #day only - max: 2
      "Optional: Year of date of birth": {  method: "date_of_birth_yyyy" }, #year only - max: 4
      "Month of date you can begin to receive mail at this address": {},
      "Day of date you can begin to receive mail at this address": {},
      "Year of date you can begin to receive mail at this address": {},
      "Month of date of return to residence address": {},
      "Day of date of return to residence address": {},
      "Year of date of return to residence address": {},
      "Reason for voting by mail:": {
        options: ["65 years of age or older. (Complete box #6a", "Confinement to jail. (Complete box #6b)", "Disability. (Complete box #6a", "Expected absence from the county. (Complete box #6b and box #8"]
      },
      "If requesting this ballot be mailed to a different address (other than residense), indicate where the ballot will be mailed": {
        options: ["Address of the jail", "Address outside the county", "Hospital", "Mailing address as listed on my voter registration certificate", "Nursing home, assisted living facility, or long term care facility", "Relative; relationship", "Retirement center"]
      },
      #Date of signature
      "City of witness": {},
      "Zip code of witness": {},
      "State of witness": {},
      "Street address of witness": {},
      "Apartment number (if applicable) of witness": {},
      "Select only if your 65 or older or live with a disability:": {
        method: "novemeber_election_if_over_65",
        options: ["Any resulting runoff", "May election", "November election", "Off", "Other"]
        # conditional static value of "November election" if applicant selects "65 years of age or older. (Complete box #6a" radio option under "Reason for voting by mail:"
      },
      "Select only if absent from the county or confined to jail:": {
        method: "november_election_if_confined_to_jail",
        options: ["Any resulting runoff", "May election", "November election", "Off", "Other"]
        # conditional static value of "November election" if applicant selects "Confinement to jail. (Complete box #6b)" radio option under "Reason for voting by mail:"
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
      "1 Last Name Please print information": {
        method: "last_name"
      },
      "Relative; relationship": {}, #this is the text field for the radio option
      "early voting clerks fax": {}, #only needed if applicant wants to fax their PDF application
      "City": {
        method: "city"
      },
      "Early voting clerk's address": {}, #only needed if applicant wants to email their PDF application
    }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def november_election_if_over_65
    if self.send(self.class.make_method_name("Reason for voting by mail:")) == "65 years of age or older. (Complete box #6a"
      "November election" 
    else
      "Off"
    end
  end
  
  def november_election_if_confined_to_jail
    if self.send(self.class.make_method_name("Reason for voting by mail:")) == "Confinement to jail. (Complete box #6b)"
      "November election" 
    else
      "Off"
    end
  end
  
  
  
  def form_field_items
    [
      {"Reason for voting by mail:": {required: true, type: :radio}}, 
      {"has_mailing_address": {type: :checkbox}},
      {"3 Mail my ballot to If mailing address differs from residence address please complete Box  7": {visible: "has_mailing_address"}},
      {"City": {visible: "has_mailing_address"}},
      {"State": {visible: "has_mailing_address", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP Code_2": {visible: "has_mailing_address", min: 5, max: 10}},
      {"If requesting this ballot be mailed to a different address (other than residense), indicate where the ballot will be mailed": {
        visible: "has_mailing_address", type: :radio}}, 
      {"Relative; relationship": {visible: "if_requesting_this_ballot_be_mailed_to_a_different_address__other_than_residense___indicate_where_the_ballot_will_be_mailed_relative__relationship"}},
      {"If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below": {
        type: :checkbox}}, 
      {"If you assisted the applicant in completing this application in the applicants presence or emailedmailed or faxed the application on behalf of the applicant please check this box as an Assistant and sign below": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below"), 
        type: :checkbox}},
      {"Refer to Instructions on back for clarification": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")}},
        #witness' relationship to applicant
      {"Street address of witness": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")}}, 
      {"Apartment number (if applicable) of witness": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")}}, 
      {"City of witness": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")}},
      {"State of witness": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below"),
        type: :select, options: GeoState.collection_for_select, include_blank: true}}, 
      {"Zip code of witness": {
        visible: self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")}},
    ]
  end
  
  def custom_form_field_validations
    if self.has_mailing_address.to_s == "1"
      ["3 Mail my ballot to If mailing address differs from residence address please complete Box  7", "City", "State", "ZIP Code_2"].each do |f|
        custom_validates_presence_of(f)
        #errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
      end
    end
    if self.send(self.class.make_method_name("If requesting this ballot be mailed to a different address (other than residense), indicate where the ballot will be mailed")) == "relative__relationship"
      custom_validates_presence_of("Relative; relationship")
    end
    if self.send(self.class.make_method_name("If applicant is unable to mark Box 10 and you are acting as a Witness to that fact please check this box and sign below")) == "1"
      ["Refer to Instructions on back for clarification",
      "Street address of witness",
      "Apartment number (if applicable) of witness",
      "City of witness",
      "State of witness",
      "Zip code of witness"].each do |f|
        custom_validates_presence_of(f)
      end
    end
  end

  
end