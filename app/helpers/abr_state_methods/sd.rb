module AbrStateMethods::SD
  
  PDF_FIELDS = {
    "County": {},
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle NamesInitial": {
      method: "middle_name"
    },
    "Suffix": {
      method: "name_suffix"
    },
    "Voter Registration Address": {
      method: "address_line_1"
    },
    "Apt or Lot": {
      method: "unit"
    },
    "City State": {
      method: "address_city_state"
    }, 
    "Zip Code": {
      method: "zip"
    },
    "SELECT THE ELECTIONS YOU ARE REQUESTING AN ABSENTEE BALLOT FOR If your address changes after this is submitted you must submit a new form": {},
    "City State_2": {},
    "Zip Code_2": {},
    "Daytime telephone number": {
      method: "phone"
    },
    "Last Name_2": {},
    "First Name_2": {},
    "Daytime telephone": {},
    "Apt or Lot_2": {},
    "Zip Code_3": {},
    "Box 1": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Box 2": { 
      options: ["Off", "Yes"],
      value: "Yes"
    },
    "Box 3": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Box 4": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Box 5": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Box 6": { 
      options: ["Off", "Yes"],
      value: "Off"
    },
    "Email address": {
      method: "email_if_military_opt_in"
    },
    "verification": { 
      options: ["Off", "notarized", "photo"],
      value: "Off"
    },
    "am_resident": { 
      options: ["Off", "No", "Yes"],
      value: "Off"
    },
    "am_student": { 
      options: ["Off", "No", "Yes"],
      value: "Off"
    },
    "Box 14": { options: ["Off", "Yes"] }, # uocava_1 yes
    "Box 15": { options: ["Off", "Yes"] }, # uocava_1 no
    "Box 16": { options: ["Off", "Yes"] }, # uocava_2 yes
    "Box 17": { options: ["Off", "Yes"] }, # uocava_2 no
    "Box 18": { options: ["Off", "Yes"] }, # uocava_3 yes
    "Box 19": { options: ["Off", "Yes"] }, # uocava_3 no
    
    "Party": { 
      options: ["Off", "Democratic", "Libertarian", "Non-Political"],
      value: "Off"
    },
    #"messenger_signature": {},
    #"voter_signature_2": {},
    #"received_date": {},
    #"received_time": {},
    #"voter_signature": {},
    #"sworn_month": {},
    #"sworn_day": {},
    #"voter_signed_date": {},
    #"notary_signature": {},
    #"notary_comission_expiry": {},
    "to serve as my authorized messenger to pick up my absentee ballot I": {},
    "As the authorized messenger I acknowledge receipt of the ballot for": {},
  }
  EXTRA_FIELDS = ["has_mailing_address", "messenger", "uocava", "uocava_email"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Aurora",
        "Beadle",
        "Bennett",
        "Bon Homme",
        "Brookings",
        "Brown",
        "Brule",
        "Buffalo",
        "Butte",
        "Campbell",
        "Charles Mix",
        "Clark",
        "Clay",
        "Codington",
        "Corson",
        "Custer",
        "Davison",
        "Day",
        "Deuel",
        "Dewey",
        "Douglas",
        "Edmunds",
        "Fall River",
        "Faulk",
        "Grant",
        "Gregory",
        "Haakon",
        "Hamlin",
        "Hand",
        "Hanson",
        "Harding",
        "Hughes",
        "Hutchinson",
        "Hyde",
        "Jackson",
        "Jerauld",
        "Jones",
        "Kingsbury",
        "Lake",
        "Lawrence",
        "Lincoln",
        "Lyman",
        "McCook",
        "McPherson",
        "Marshall",
        "Meade",
        "Mellette",
        "Miner",
        "Minnehaha",
        "Moody",
        "Pennington",
        "Perkins",
        "Potter",
        "Roberts",
        "Sanborn",
        "Shannon",
        "Spink",
        "Stanley",
        "Sully",
        "Todd",
        "Tripp",
        "Turner",
        "Union",
        "Walworth",
        "Yankton",
        "Ziebach",
      ]}},
      {"has_mailing_address": {type: :checkbox}},
      {"SELECT THE ELECTIONS YOU ARE REQUESTING AN ABSENTEE BALLOT FOR If your address changes after this is submitted you must submit a new form": {visible: "has_mailing_address", required: :if_visible}},
      {"City State_2": {classes: "three-quarter", visible: "has_mailing_address", required: :if_visible}},
      {"Zip Code_2": {classes: "quarter last", visible: "has_mailing_address", required: :if_visible}},
      {"messenger": {type: :checkbox}},
      {"First Name_2": {classes: "indent half", visible: "messenger", required: :if_visible}},
      {"Last Name_2": {classes: "indent half not-first last ", visible: "messenger", required: :if_visible}},
      {"to serve as my authorized messenger to pick up my absentee ballot I": {classes: "indent three-quarter", visible: "messenger", required: :if_visible}},
      {"Apt or Lot_2": {classes: "indent last quarter", visible: "messenger"}},
      {"As the authorized messenger I acknowledge receipt of the ballot for": {classes: "indent three-quarter", visible: "messenger", required: :if_visible}},
      {"Zip Code_3": {classes: "indent last quarter",visible: "messenger", required: :if_visible}},
      {"Daytime telephone": {classes: "indent", visible: "messenger", required: :if_visible}},
      {"uocava": {type: :checkbox}},
      {"uocava_1": {classes: "indent", visible: "uocava", type: :radio, options: ["Yes", "No"], required: :if_visible}},
      {"uocava_2": {classes: "indent", visible: "uocava", type: :radio, options: ["Yes", "No"], required: :if_visible}},
      {"uocava_3": {classes: "indent", visible: "uocava", type: :radio, options: ["Yes", "No"], required: :if_visible}},
      {"uocava_email": {classes: "indent", visible: "uocava", type: :radio, options: ["Yes", "No"], required: :if_visible}}
    ]
  end
  
  # "Box 14": { options: ["Off", "Yes"] }, # uocava_1 yes
  # "Box 15": { options: ["Off", "Yes"] }, # uocava_1 no
  def uocava_1
    if self.box_14 == "Yes"
      return "Yes"
    elsif self.box_15 == "Yes"
      return "No"
    end
    return nil
  end
  def uocava_1=(value)
    if value == "Yes"
      self.box_14 = "Yes"
      self.box_15 = "Off"
    elsif value == "No"
      self.box_14 = "Off"
      self.box_15 = "Yes"
    end
  end
  
  # "Box 16": { options: ["Off", "Yes"] }, # uocava_2 yes
  # "Box 17": { options: ["Off", "Yes"] }, # uocava_2 no
  def uocava_2
    if self.box_16 == "Yes"
      return "Yes"
    elsif self.box_17 == "Yes"
      return "No"
    end
    return nil
    
  end
  def uocava_2=(value)
    if value == "Yes"
      self.box_16 = "Yes"
      self.box_17 = "Off"
    elsif value == "No"
      self.box_16 = "Off"
      self.box_17 = "Yes"
    end
  end
  
  
  # "Box 18": { options: ["Off", "Yes"] }, # uocava_3 yes
  # "Box 19": { options: ["Off", "Yes"] }, # uocava_3 no
  def uocava_3
    if self.box_18 == "Yes"
      return "Yes"
    elsif self.box_19 == "Yes"
      return "No"
    end
    return nil
    
  end
  def uocava_3=(value)
    if value == "Yes"
      self.box_18 = "Yes"
      self.box_19 = "Off"
    elsif value == "No"
      self.box_18 = "Off"
      self.box_19 = "Yes"
    end
    
  end
  
  
  
  def email_if_military_opt_in
    if uocava == "1" && uocava_email == "Yes"
      email
    else
      nil
    end
  end
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end