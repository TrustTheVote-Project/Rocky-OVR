module AbrStateMethods::SD
  
  PDF_FIELDS = {
    "County": {},
    "Last Name": {
      method: "last name"
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
    "City State": {}, #TODO- make this work
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
      value: "On"
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
    "Email address": {},
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
      {"SELECT THE ELECTIONS YOU ARE REQUESTING AN ABSENTEE BALLOT FOR If your address changes after this is submitted you must submit a new form": {visible: "has_mailing_address"}},
      {"City State_2": {visible: "has_mailing_address"}},
      {"Zip Code_2": {visible: "has_mailing_address"}},
      {"messenger": {type: :checkbox}},
      {"Last Name_2": {visible: "messenger"}},
      {"First Name_2": {visible: "messenger"}},
      {"authorized_address": {visible: "messenger"}},
      {"Apt or Lot_2": {visible: "messenger"}},
      {"authorized_city_state": {visible: "messenger"}},
      {"Zip Code_3": {visible: "messenger"}},
      {"Daytime telephone": {visible: "messenger"}},
      {"uocava": {type: :checkbox}},
      {"UOCAVA_1": {visible: "uocava", type: :radio}},
      {"UOCAVA_2": {visible: "uocava", type: :radio}},
      {"UOCAVA_3": {visible: "uocava", type: :radio}},
      {"uocava_email": {visible: "uocava", type: :radio, options: ["Yes", "No"]}}, #TODO - if "Yes", autofill above "Email address"
    ]
  end
  #e.g.
  # [
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
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end