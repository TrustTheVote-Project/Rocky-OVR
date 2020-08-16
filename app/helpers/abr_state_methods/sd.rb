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
    "UOCAVA_1": { options: ["Yes", "No"] },
    "UOCAVA_2": { options: ["Yes", "No"] },
    "UOCAVA_3": { options: ["Yes", "No"] },
    "Party": { 
      options: ["Off", "Democratic", "Libertarian", "Non-Political"],
      value: "Off"
    },
    #"messenger_signature": {},
    #"voter_signature_2": {},
    "mesenger_for_other": { 
      options: ["Off", "No", "Yes"],
      value: "Off"
    },
    #"received_date": {},
    #"received_time": {},
    #"voter_signature": {},
    #"sworn_month": {},
    #"sworn_day": {},
    #"voter_signed_date": {},
    #"notary_signature": {},
    #"notary_comission_expiry": {},
    "authorized_address": {},
    "authorized_city_state": {},
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
      {"City State_2": {visible: "has_mailing_address", required: :if_visible}},
      {"Zip Code_2": {visible: "has_mailing_address", required: :if_visible}},
      {"messenger": {type: :checkbox}},
      {"Last Name_2": {visible: "messenger", required: :if_visible}},
      {"First Name_2": {visible: "messenger", required: :if_visible}},
      {"authorized_address": {visible: "messenger", required: :if_visible}},
      {"Apt or Lot_2": {visible: "messenger"}},
      {"authorized_city_state": {visible: "messenger", required: :if_visible}},
      {"Zip Code_3": {visible: "messenger", required: :if_visible}},
      {"Daytime telephone": {visible: "messenger", required: :if_visible}},
      {"uocava": {type: :checkbox}},
      {"UOCAVA_1": {visible: "uocava", type: :radio, required: true}},
      {"UOCAVA_2": {visible: "uocava", type: :radio, required: true}},
      {"UOCAVA_3": {visible: "uocava", type: :radio, required: true}},
      {"uocava_email": {visible: "uocava", type: :radio, options: ["Yes", "No"], required: true}}
    ]
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