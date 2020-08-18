module AbrStateMethods::NC
  
  PDF_FIELDS = {
    "Voter's Last Name": {
      method: "last_name"
    },
    "Voter's First Name": {
      method: "first_name"
    },
    "Voter's Middle Name": {
      method: "middle_name"
    },
    "Voter's Suffix": {
      method: "name_suffix"
    },
    "Voter's Month of Birth": {
      method: "date_of_birth_mm"
    },
    "Voter's Date of Birth": {
      method: "date_of_birth_dd"
    },
    "Voter's Year of Birth": {
      method: "date_of_birth_yyyy"
    },
    "Voter's Previous Last Name": {},
    "Voter's Previous First Name": {},
    "Voter's Previous Middle Name": {},
    "NC Driver Licence or NCID Number": {},
    "SSN1": { method: "ssn_1" },
    "SSN2": { method: "ssn_2" },
    "SSN3": { method: "ssn_3" },
    "SSN4": { method: "ssn_4" },
    "Voter's Current NC Residential Street Address": {
      method: "address"
    },
    "Voter's regular mailing address": {},
    "Moved Month": { method: "date_moved_mm" },
    "Moved Date": { method: "date_moved_dd" },
    "Moved Year": { method: "date_moved_yyyy" },
    "Voter's Residential City": {
      method: "city"
    },
    "Voter's Residential State": {
      method: "home_state_abbrev"
    },
    "Voter's Residential Zip Code": {
      method: "zip"
    },
    "Voter's Residential County": {},
    "Voter's E-mail address": {
      method: "email"
    },
    "Voter's phone number": {
      method: "phone"
    },
    "Mailing Address for Ballot": { method: "residential_or_ballot_mailing_address" },
    "Check if you would like to request absentee ballots for all elections": { options: ["Off", "On"], value: "Off" },
    "Mailing City": {
      method: "residential_or_ballot_city"
    },
    "Mailing State": {
      method: "residential_or_ballot_state"
    },
    "Mailing Zip Code": {
      method: "residential_or_ballot_zip"
    },
    "Near Relative or Legal Guardian's Name": {},
    "Near Relative or Legal Guardian's Relationship to Voter": {},
    "Near Relative or Legal Guardian's Address": {},
    "Near Relative or Legal Guardian's City": {},
    "Near Relative or Legal Guardian's State": {},
    "Near Relative or Legal Guardian's Zip Code": {},
    "Voter Assistants Name": {},
    "Voter Assistant's Address": {},
    "Voter Assistant's City": {},
    "Voter Assistant's State": {},
    "Voter Assistant's Zip Code": {},
    "Name and Address of Facility": {},
    "Patient Yes": { options: ["Off", "On"] },
    "Patient No": { options: ["Off", "On"] },
    "Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence": { options: ["Off", "On"] },
    "US citizen outside the United States": { options: ["Off", "On"] },
    "Overseas Address": {},
    "Overseas Mailing Address": { },
    "Overseas E-Mail address": {  method: "uocava_email_address_if_selected" },
    "Overseas Fax Number": {},
    "lived_here_long": { options: ["No", "Yes"] },
    #"voter_signature": {},
    #"other_signature": {},
    #"date_signed_voter": {},
    #"date_signed_other": {},
  }
  EXTRA_FIELDS = ["ssn1234", "has_mailing_address", "identification", "previous_name", "ballot_address", "ballot_mailing_address", "ballot_city", "ballot_state", "ballot_zip", "relative_request", "assistant", "uocava", "uocava_ballot", "date_moved_mm", "date_moved_dd", "date_moved_yyyy"]

  def ssn_1
    !ssn1234.blank? && ssn1234[0]
  end
  def ssn_2
    !ssn1234.blank? && ssn1234[1]
  end
  def ssn_3
    !ssn1234.blank? && ssn1234[2]
  end
  def ssn_4
    !ssn1234.blank? && ssn1234[3]
  end
  
  def form_field_items
    [
      {"Voter's Residential County": {type: :select, required: true, include_blank: true, options: [
        "Alamance",
        "Alexander",
        "Alleghany",
        "Anson",
        "Ashe",
        "Avery",
        "Beaufort",
        "Bertie",
        "Bladen",
        "Brunswick",
        "Buncombe",
        "Burke",
        "Cabarrus",
        "Caldwell",
        "Camden",
        "Carteret",
        "Caswell",
        "Catawba",
        "Chatham",
        "Cherokee",
        "Chowan",
        "Clay",
        "Cleveland",
        "Columbus",
        "Craven",
        "Cumberland",
        "Currituck",
        "Dare",
        "Davidson",
        "Davie",
        "Duplin",
        "Durham",
        "Edgecombe",
        "Forsyth",
        "Franklin",
        "Gaston",
        "Gates",
        "Graham",
        "Granville",
        "Greene",
        "Guilford",
        "Halifax",
        "Harnett",
        "Haywood",
        "Henderson",
        "Hertford",
        "Hoke",
        "Hyde",
        "Iredell",
        "Jackson",
        "Johnston",
        "Jones",
        "Lee",
        "Lenoir",
        "Lincoln",
        "McDowell",
        "Macon",
        "Madison",
        "Martin",
        "Mecklenburg",
        "Mitchell",
        "Montgomery",
        "Moore",
        "Nash",
        "New Hanover",
        "Northampton",
        "Onslow",
        "Orange",
        "Pamlico",
        "Pasquotank",
        "Pender",
        "Perquimans",
        "Person",
        "Pitt",
        "Polk",
        "Randolph",
        "Richmond",
        "Robeson",
        "Rockingham",
        "Rowan",
        "Rutherford",
        "Sampson",
        "Scotland",
        "Stanly",
        "Stokes",
        "Surry",
        "Swain",
        "Transylvania",
        "Tyrrell",
        "Union",
        "Vance",
        "Wake",
        "Warren",
        "Washington",
        "Watauga",
        "Wayne",
        "Wilkes",
        "Wilson",
        "Yadkin",
        "Yancey",
      ]}},
      {"lived_here_long": {type: :radio}},
      {"date_moved": {type: :date, m: "date_moved_mm", d: "date_moved_dd", y: "date_moved_yyyy", visible: "lived_here_long_no", }},
      {"identification": {
        type: :radio,
        required: true,
        options: ["dln", "ssn"]}},
      {"NC Driver Licence or NCID Number": {visible: "identification_dln"}},
      {"ssn1234": {visible: "identification_ssn"}}, 
      {"has_mailing_address": {type: :checkbox}},
      {"Voter's regular mailing address": {visible: "has_mailing_address", required: :if_visible}},
      {"ballot_address": {type: :checkbox}},
      {"ballot_mailing_address": {visible: "ballot_address", required: :if_visible}},
      {"ballot_city": {visible: "ballot_address", required: :if_visible}},
      {"ballot_state": {visible: "ballot_address", required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ballot_zip": {visible: "ballot_address", required: :if_visible, min: 5, max: 10}},
      {"previous_name": {type: :checkbox}},
      {"Voter's Previous First Name": {visible: "previous_name", required: :if_visible}},
      {"Voter's Previous Middle Name": {visible: "previous_name"}},
      {"Voter's Previous Last Name": {visible: "previous_name", required: :if_visible}},
      {"uocava": {type: :checkbox}},
      {"military_or_overseas": { type: :radio, options: ["military", "overseas"], visible: "uocava"}},
      {"US citizen outside the United States": {visible: "uocava", type: :checkbox}},
      {"Overseas Address": {visible: "uocava"}},
      {"uocava_ballot": {visible: "uocava", required: :if_visible, type: :radio, options: ["mail", "email"]}}, 
      {"Overseas Mailing Address": {visible: "uocava_ballot_mail"}},
      {"relative_request": {type: :checkbox}},
      {"Near Relative or Legal Guardian's Name": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's Relationship to Voter": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's Address": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's City": {visible: "relative_request"}},
      {"Near Relative or Legal Guardian's State": {visible: "relative_request", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Near Relative or Legal Guardian's Zip Code": {visible: "relative_request", min: 5, max: 10}},
      {"assistant": {type: :checkbox}},
      {"Voter Assistants Name": {visible: "assistant"}},
      {"Voter Assistant's Address": {visible: "assistant"}},
      {"Voter Assistant's City": {visible: "assistant"}},
      {"Voter Assistant's State": {visible: "assistant", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"Voter Assistant's Zip Code": {visible: "assistant", min: 5, max: 10}},
      {"patient": {type: :radio, options: ["Yes", "No"]}}, 
      {"Name and Address of Facility": {visible: "patient_yes", required: :if_visible}}
    ]
  end
  
  def military_or_overseas
    if self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")) == "On"
      return "military"
    elsif self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")) == "Off"
      return "overseas"
    end
    return nil
  end
  
  def military_or_overseas=(val)
    self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")+"=", "Off")
    self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")+"=", "Off")
    if val == "military"
      self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")+"=", "On")
    elsif val == "overseas"
      self.send(self.class.make_method_name("Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence")+"=", "On")
    end
  end
  
  def patient
    if self.patient_yes == "On"
      return "Yes"
    elsif self.patient_no == "On"
      return "No"
    end
    return nil
  end
  
  def patient=(value)
    self.patient_yes = "Off"
    self.patient_no = "Off"
    if value == "Yes"
      self.patient_yes = "On"
    elsif value == "No"
      self.patient_no = "On"
    end
  end
  
  def uocava_email_address_if_selected
    email if uocava_ballot == "email"
  end
  
  def residential_or_ballot_mailing_address
    if self.ballot_address == "1"
      self.ballot_mailing_address
    else
      self.address
    end
  end
  def residential_or_ballot_city
    if self.ballot_address == "1"
      self.ballot_city
    else
      self.city
    end
  end
  def residential_or_ballot_state
    if self.ballot_address == "1"
      self.ballot_state
    else
      self.home_state_abbrev
    end
  end
  def residential_or_ballot_zip
    if self.ballot_address == "1"
      self.ballot_zip
    else
      self.zip
    end
  end
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end