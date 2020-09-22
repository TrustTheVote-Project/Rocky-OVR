module AbrStateMethods::NC
  
  PDF_FIELDS = {
    #"Voter's Last Name": {
    "Last_Name": {
      method: "last_name"
    },
    #"Voter's First Name": {
    "First_Name": {
      method: "first_name"
    },
    #"Voter's Middle Name": {
    "Middle_Name": {
      method: "middle_name"
    },
    #"Voter's Suffix": {
    "Suffix": {
      method: "name_suffix"
    },

    #"Voter's Previous Last Name": {},
    #"Voter's Previous First Name": {},
    #"Voter's Previous Middle Name": {},
    "Former_Name": {},

    "DOB": {
      'method': "date_of_birth_mm_dd_yyyy",
    },

    #"NC Driver Licence or NCID Number": {},
    "ID_Number": {sensitive:true},
    "SSN4":  {sensitive:true},



    #"Moved Month": { method: "date_moved_mm" },
    #"Moved Date": { method: "date_moved_dd" },
    #"Moved Year": { method: "date_moved_yyyy" },

    "MovedDate": {
      method: 'date_moved_mm_dd_yyyy',
    },
    
    #"Voter's Current NC Residential Street Address": {
    "NCStreet": {
        method: "address"
      },

    #"Voter's Residential City": {
    "NCCity": {
      method: "city"
    },
    #"Voter's Residential State": {
    "NCState": {
      method: "home_state_abbrev"
    },
    #"Voter's Residential Zip Code": {
    "NCZip": {
      method: "zip"
    },
    #"Voter's Residential County": {},
    "NCCounty": {},

    #"Voter's regular mailing address": {},
    "NCMailing1": {
      method:"reg_mail_1"
    },
    "NCMailing2": {
      method: "reg_mail_rest"
    },

    #"Voter's E-mail address": {
    "ContactEmail": {
      method: "email"
    },
    #"Voter's phone number": {
    "ContactPhone": {
      method: "phone"
    },

    #"Check if you would like to request absentee ballots for all elections": {
    "continued_request":{
      options: ["Off", "On"], 
      value: "Off" 
    },
    #Ballot mailing address below
    #"Mailing Address for Ballot": {
    "MailStreet": {
      #method: "residential_or_ballot_mailing_address" 
    },
    #"Mailing City": {
      "MailCity": {
      #method: "residential_or_ballot_city"
    },
    #"Mailing State": {
    "MailState": {
      #method: "residential_or_ballot_state"
    },
    #"Mailing Zip Code": {
      "MailZip": {
      #method: "residential_or_ballot_zip"
    },
    #"Near Relative or Legal Guardian's Name": {},
    #"Near Relative or Legal Guardian's Relationship to Voter": {},
    #"Near Relative or Legal Guardian's Address": {},
    #"Near Relative or Legal Guardian's City": {},
    #"Near Relative or Legal Guardian's State": {},
    #"Near Relative or Legal Guardian's Zip Code": {},
   
    "RelativeName": {},
    "RelativeRelationship": {},
    "RelativeAddress": {},
    "RelativeCity": {},
    "RelativeState": {},
    "RelativeZip": {},

    "Voter Assistants Name": {},
    "Voter Assistant's Address": {},
    "Voter Assistant's City": {},
    "Voter Assistant's State": {},
    "Voter Assistant's Zip Code": {},

    "AssistantFullName": {},
    "AssistantAddress": {},
    "AssistantAddress2": {
      method: "assistant_address_rest"
    },


    
    #"Name and Address of Facility": {},
    "HopitalFacilityName": {},

    #"Patient Yes": { options: ["Off", "On"] },
    #"Patient No": { options: ["Off", "On"] },


    #"Member of the Uniformed Services or Merchant Marine on active duty or eligible spousedependent and currently absent from county of residence": { options: ["Off", "On"] },

    
    
    
    #"US citizen outside the United States": { options: ["Off", "On"] },
    "UOCAVA": { options: [ "citizen", "military"] },

    #"Overseas Address": {},
    "UOCAVAAddress":{},
    "UOCAVAAddress2":{},

    "delivery_method": { 
      options: [ "email", "mail"] 
    }, #fax not supported?




    #"Overseas Mailing Address": { },
    "Mailing1":{},
    "Mailing2":{},
    
    #"Overseas E-Mail address": { 
    "Email": {
      method: "uocava_email_address_if_selected" 
    },

    #"Overseas Fax Number": {
      "Fax": {
    },
  
    "lived_here_long": { options: ["No", "Yes"] },
    #"voter_signature": {},
    #"other_signature": {},
    #"date_signed_voter": {},
    #"date_signed_other": {},

  }
  EXTRA_FIELDS = [ "has_mailing_address", "identification", "previous_name", "ballot_address", "ballot_mailing_address", "ballot_city", "ballot_state", "ballot_zip", "relative_request", "assistant", "date_moved_mm", "date_moved_dd", "date_moved_yyyy","uocava_option","AssistantAddressInput", "assistantcity", "assistantstate", "assistantzip", "patient", "reg_mail_street","reg_mail_city","reg_mail_state","reg_mail_zip"]


  def form_field_items
    [

      {"previous_name": {type: :checkbox}},

      {"Former_Name": {visible: "previous_name", required: :if_visible}},


      {"identification": {
        type: :radio,
        required: true,
        options: ["dln", "ssn"]}},
      {"ID_Number": {visible: "identification_dln", required: "star", regexp: /\A\d{1,12}\z/}},
      {"SSN4": {visible: "identification_ssn", required: "star", classes: "half", length:4, regexp: /\A\d{4}\z/}},

      #{"Voter's Residential County":
      {"NCCounty":
         {type: :select, required: true, include_blank: true, options: [
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
      {"lived_here_long": {type: :radio, required: true}},
      {"date_moved": {type: :date, m: "date_moved_mm", d: "date_moved_dd", y: "date_moved_yyyy", visible: "lived_here_long_no", required: 'star' }},

      {"has_mailing_address": {type: :checkbox}},
      {"reg_mail_street":{visible: "has_mailing_address", required: :if_visible}},
      {"reg_mail_city":{visible: "has_mailing_address", required: :if_visible, classes:"half"}},
      {"reg_mail_state":{visible: "has_mailing_address",type: :select, options: GeoState.collection_for_select, include_blank: true, required: :if_visible, classes:"quarter"}},
      {"reg_mail_zip":{visible: "has_mailing_address", required: :if_visible, classes:"quarter last"}},

      #{"Voter's regular mailing address": {visible: "has_mailing_address", required: :if_visible}},
      #{"NCMailing1": {visible: "has_mailing_address", required: :if_visible}},
      #{"NCMailing2": {visible: "has_mailing_address", required: :if_visible}},
     
      {"ballot_address": {type: :checkbox}},
      {"MailStreet":{visible: "ballot_address", required: :if_visible}},
      {"MailCity":{visible: "ballot_address", required: :if_visible, classes:"half"}},
      {"MailState":{visible: "ballot_address", type: :select, options: GeoState.collection_for_select, include_blank: true, required: :if_visible, classes:"quarter"}},
      {"MailZip":{visible: "ballot_address", required: :if_visible, classes:"quarter last"}},


      #{"ballot_mailing_address": {visible: "ballot_address", required: :if_visible}},
      #{"ballot_city": {visible: "ballot_address", required: :if_visible, classes: "half"}},
      #{"ballot_state": {visible: "ballot_address", classes: "quarter", required: :if_visible, type: :select, options: GeoState.collection_for_select, include_blank: true}},
      #{"ballot_zip": {visible: "ballot_address", classes: "quarter last", required: :if_visible, min: 5, max: 10}},
     
       
      {"relative_request": {type: :checkbox}},
      {"RelativeName": {visible: "relative_request",required: :if_visible}},
      {"RelativeRelationship": {visible: "relative_request",required: :if_visible}},
      {"RelativeAddress": {visible: "relative_request", required: :if_visible}},
      {"RelativeCity": {visible: "relative_request", required: :if_visible, classes:"half"}},
      {"RelativeState": {visible: "relative_request", type: :select, options: GeoState.collection_for_select, include_blank: true, required: :if_visible, classes:"quarter"}},
      {"RelativeZip": {visible: "relative_request", min: 5, max: 10, required: :if_visible, classes:"quarter last"}},
      
      {"assistant": {type: :checkbox}},
      {"AssistantFullName": {visible: "assistant", required: :if_visible}},
      {"AssistantAddress": {visible: "assistant", required: :if_visible}},
      {"assistantcity": {visible: "assistant",  required: :if_visible, classes: "half"}},
      {"assistantstate": {visible: "assistant",  required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"assistantzip": {visible: "assistant",  required: :if_visible, classes: "quarter last", min: 5, max: 10}},
      
      {"patient": {type: :checkbox}}, 
      {"HopitalFacilityName": {visible: "patient", required: :if_visible}},

      {"uocava_option": {type: :checkbox}},
      {
        #"military_or_overseas": {
      "UOCAVA": {
        type: :radio, 
        options: ["military", "citizen"],
        visible: "uocava_option",  
        required: :if_visible}},
      #{"Overseas Address":
      {"UOCAVAAddress":
         {visible: "uocava_option"}},
      #{"UOCAVAAddress2":
      #  {visible: "uocava_option"}},
      {"delivery_method": {
        visible: "uocava_option", 
        required: :if_visible, 
        type: :radio, 
        options: ["mail", "email"]}}, 
      #{"Mailing1": {
      #  visible: "delivery_method_mail",
      #  required: "star",
      #  max: 17
      # }},
      {"Mailing2": {
        visible: "delivery_method_mail",
        required: "star",
        #max:29
        }},

    ]
  end
  
  def uocava_email_address_if_selected
    email if delivery_method == "email"
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

  def reg_mail_1
    if self.has_mailing_address == "1"
      self.reg_mail_street
    end
  end

  def reg_mail_rest
    if self.has_mailing_address == "1"
      values= ["reg_mail_city", "reg_mail_state", "reg_mail_zip"].map {|m| self.send(m).to_s}
      return (values.compact.join(" "))
    end
  end
  def assistant_address_rest
    if self.assistant == "1"
      values= ["assistantcity", "assistantstate", "assistantzip"].map {|m| self.send(m).to_s}
      return (values.compact.join(" "))
    end
  end

  def test_date(datestring)
    begin
      @mydate = Date.strptime(datestring, "%m/%d/%Y")
      return true
    rescue ArgumentError
      return false
    end
  end

  def  date_moved_mm_dd_yyyy
    dates = [date_moved_mm, date_moved_dd, date_moved_yyyy].collect {|d| d.blank? ? nil : d}.compact
    dates && dates.length == 3 ? dates.join("/") : nil
  end

  
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery

    #date_moved

    if self.identification.to_s=='ssn' 
      custom_validates_presence_of("SSN4")
    elsif self.identification.to_s=='dln'
      custom_validates_presence_of("ID_Number")
    end

    if (self.lived_here_long.to_s=='No' && !test_date(self.date_moved_mm_dd_yyyy.to_s))
        errors.add("date_moved",custom_format_message("bad_date"))       
    end

    if self.delivery_method.to_s=='mail' 
      custom_validates_presence_of("Mailing2")
    end

  end
  
 
end