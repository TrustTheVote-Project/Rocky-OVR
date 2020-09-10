module AbrStateMethods::WI
  
  PDF_FIELDS = {
    "Town Village City": {
      method: "city"
    },
    "County": {},
    "Last Name": {
      method: "last_name"
    },
    "First Name": {
      method: "first_name"
    },
    "Middle Name": {
      method: "middle_name"
    },
    "Suffix eg Jr II etc": {
      method: "name_suffix"
    },
    "Date of Birth MMDDYYYY": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "Residence Address Street Number  Name": {
      method: "address_line_1"
    },
    "Apt Number": {
      method: "unit"
    },
    "City": {
      method: "city"
    },
    "State  ZIP": {}, #TODO - make this work.
    "Mailing Address Street Number  Name": {},
    "Apt Number_2": {},
    "City_2": {},
    "State  ZIP_2": {},
    "Care Facility Name if applicable": {},
    "C  O if applicable": {},
    "Fax Number": {},
    "Email Address": {
      method: "receive_by_email" #TODO - see below
    },
    "The elections on the following dates": {
      value: "11/03/2020"
    },
    "Agent Last Name": {},
    "Agent First Name": {},
    "Agent Middle Name": {},
    "Agent Address": {},
    #"Todays Date": {},
    #"Todays Date_2": {},
    "Certify": { options: ["Yes"] },
    "Municipality": { options: ["City", "Town", "Village"] },
    "UOCAVA": { options: ["Military", "Permanent_Overseas", "Temporary_Overseas"] },
    "receive_by": { options: ["Clerk_Office", "Email", "Mail", "Fax"] },
    "which_election": { 
      options: ["dated_election", "indefinitely", "this_year"],
      value: "dated_election"
    },
    #"voter_signature": {},
    #"agent_signature_1": {},
    #"agent_signature_2": {},
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  # def receive_by_email
  #   # TODO when "receive_by_email" is selected, it should autofill with "email" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"Municipality": {type: :radio, required: true}},
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Adams",
        "Ashland",
        "Barron",
        "Bayfield",
        "Brown",
        "Buffalo",
        "Burnett",
        "Calumet",
        "Chippewa",
        "Clark",
        "Columbia",
        "Crawford",
        "Dane",
        "Dodge",
        "Door",
        "Douglas",
        "Dunn",
        "Eau Claire",
        "Florence",
        "Fond Du Lac",
        "Forest",
        "Grant",
        "Green",
        "Green Lake",
        "Iowa",
        "Iron",
        "Jackson",
        "Jefferson",
        "Juneau",
        "Kenosha",
        "Kewaunee",
        "La Crosse",
        "Lafayette",
        "Langlade",
        "Lincoln",
        "Manitowoc",
        "Marathon",
        "Marinette",
        "Marquette",
        "Menominee",
        "Milwaukee",
        "Monroe",
        "Oconto",
        "Oneida",
        "Outagamie",
        "Ozaukee",
        "Pepin",
        "Pierce",
        "Polk",
        "Portage",
        "Price",
        "Racine",
        "Richland",
        "Rock",
        "Rusk",
        "St. Croix",
        "Sauk",
        "Sawyer",
        "Shawano",
        "Sheboygan",
        "Taylor",
        "Trempealeau",
        "Vernon",
        "Vilas",
        "Walworth",
        "Washburn",
        "Washington",
        "Waukesha",
        "Waupaca",
        "Waushara",
        "Winnebago",
        "Wood",
      ]}},
      {"receive_by": {type: :radio, required: true}},
      {"Fax Number": {visible: "receive_by_fax"}},
      {"has_mailing_address": {type: :checkbox}},
      {"Mailing Address Street Number  Name": {visible: "has_mailing_address", classes: "three-quarter"}},
      {"Apt Number_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"City_2": {visible: "has_mailing_address", classes: "half"}},
      {"State  ZIP_2": {visible: "has_mailing_address", classes: "half last"}},
      {"Care Facility Name if applicable": {visible: "has_mailing_address"}},
      {"C  O if applicable": {visible: "has_mailing_address"}},
      {"UOCAVA": {type: :radio}},
      {"Certify": {type: :radio}},
      {"Agent Last Name": {visible: "certify_yes"}},
      {"Agent First Name": {visible: "certify_yes", classes: "half"}},
      {"Agent Middle Name": {visible: "certify_yes", classes: "half last"}},
      {"Agent Address": {visible: "certify_yes"}},
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
  
  
  def custom_form_field_validations
    # e.g:
    # make sure delivery is selected if reason ==3
    # e.g:
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end