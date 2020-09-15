module AbrStateMethods::IL::Montgomery
  
  PDF_FIELDS = {
    "Street Address include apt lot etc if applicable": {
      method: "address"
    },
    "City": {
      method: "city"
    },
    "State": {
      method: "home_state_name"
    },
    "ZIP": {
      method: "zip"
    },
    "Daytime PhoneEmail": {
      method: "phone_and_email"
    },
    "Street Address include apt lot etc AND PO Box  if applicable": {
      method: "delivery_ballot_address"
    },
    "City_2": {
      method: "delivery_ballot_city"
    },
    "State_2": {
      method: "delivery_ballot_state"
    },
    "ZIP_2": {
      method: "delivery_ballot_zip"
    },
    "Country other than USA": {},
    #"Dated": {},
    "FirstName": {
      method: "first_name"
    },
    "LastName": {
      method: "last_name"
    },
    "2 DATE OF BIRTH Month Day Year": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "FormerName if applicable": {},
    "Suffix": {
      method: "name_suffix"
    },
    "MiddleName": {
      method: "middle_name"
    },
  }
  EXTRA_FIELDS = ["outside_usa", "has_mailing_address", "delivery_ballot_address", "delivery_ballot_city", "delivery_ballot_state", "delivery_ballot_zip"]
    
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Street Address include apt lot etc AND PO Box  if applicable": {visible: "has_mailing_address"}},
      {"City_2": {visible: "has_mailing_address", classes: "half"}},
      {"State_2": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP_2": {visible: "has_mailing_address", classes: "quarter last"}},
      {"outside_usa": {type: :checkbox}},
      {"Country other than USA": {visible: "outside_usa", required: :if_visible, type: :select, include_blank: true, options: [
        "Afghanistan",
        "Albania",
        "Algeria",
        "Andorra",
        "Angola",
        "Antigua and Barbuda",
        "Argentina",
        "Armenia",
        "Australia",
        "Austria",
        "Azerbaijan",
        "Bahamas",
        "Bahrain",
        "Bangladesh",
        "Barbados",
        "Belarus",
        "Belgium",
        "Belize",
        "Benin",
        "Bhutan",
        "Bolivia",
        "Bosnia and Herzegovina",
        "Botswana",
        "Brazil",
        "Brunei Darussalam",
        "Bulgaria",
        "Burkina Faso",
        "Burundi",
        "Cambodia",
        "Cameroon",
        "Canada",
        "Cape Verde",
        "Central African Republic",
        "Chad",
        "Chile",
        "China",
        "Colombia",
        "Comoros",
        "Congo",
        "Congo (Democratic Republic of the)",
        "Costa Rica",
        "Côte d'Ivoire",
        "Croatia",
        "Cuba",
        "Cyprus",
        "Czech Republic",
        "Denmark",
        "Djibouti",
        "Dominica",
        "Dominican Republic",
        "Ecuador",
        "Egypt",
        "El Salvador",
        "Equatorial Guinea",
        "Eritrea",
        "Estonia",
        "Ethiopia",
        "Fiji",
        "Finland",
        "France",
        "Gabon",
        "Gambia",
        "Georgia",
        "Germany",
        "Ghana",
        "Greece",
        "Grenada",
        "Guatemala",
        "Guinea",
        "Guinea-Bissau",
        "Guyana",
        "Haiti",
        "Honduras",
        "Hungary",
        "Iceland",
        "India",
        "Indonesia",
        "Iran (Islamic Republic of)",
        "Iraq",
        "Ireland",
        "Israel",
        "Italy",
        "Jamaica",
        "Japan",
        "Jordan",
        "Kazakhstan",
        "Kenya",
        "Kiribati",
        "Korea (Democratic People's Republic of)",
        "Korea (Republic of)",
        "Kuwait",
        "Kyrgyzstan",
        "Lao People's Democratic Republic",
        "Latvia",
        "Lebanon",
        "Lesotho",
        "Liberia",
        "Libya",
        "Liechtenstein",
        "Lithuania",
        "Luxembourg",
        "Macedonia (The former Yugoslav Republic of)",
        "Madagascar",
        "Malawi",
        "Malaysia",
        "Maldives",
        "Mali",
        "Malta",
        "Marshall Islands",
        "Mauritania",
        "Mauritius",
        "Mexico",
        "Micronesia (Federated States of)",
        "Republic of Moldova",
        "Monaco",
        "Mongolia",
        "Montenegro",
        "Morocco",
        "Mozambique",
        "Myanmar",
        "Namibia",
        "Nauru",
        "Nepal",
        "Netherlands",
        "New Zealand",
        "Nicaragua",
        "Niger",
        "Nigeria",
        "Norway",
        "Oman",
        "Pakistan",
        "Palau",
        "Panama",
        "Papua New Guinea",
        "Paraguay",
        "Peru",
        "Philippines",
        "Poland",
        "Portugal",
        "Qatar",
        "Romania",
        "Russian Federation",
        "Rwanda",
        "Saint Kitts and Nevis",
        "Saint Lucia",
        "Saint Vincent and the Grenadines",
        "Samoa",
        "San Marino",
        "Sao Tome and Principe",
        "Saudi Arabia",
        "Senegal",
        "Serbia",
        "Seychelles",
        "Sierra Leone",
        "Singapore",
        "Slovakia",
        "Slovenia",
        "Solomon Islands",
        "Somalia",
        "South Africa",
        "South Sudan",
        "Spain",
        "Sri Lanka",
        "Sudan",
        "Suriname",
        "Swaziland",
        "Sweden",
        "Switzerland",
        "Syrian Arab Republic",
        "Tajikistan",
        "Tanzania (United Republic of)",
        "Thailand",
        "Timor-Leste",
        "Togo",
        "Tonga",
        "Trinidad and Tobago",
        "Tunisia",
        "Turkey",
        "Turkmenistan",
        "Tuvalu",
        "Uganda",
        "Ukraine",
        "United Arab Emirates",
        "United Kingdom of Great Britain and Northern Ireland",
        "United States of America",
        "Uruguay",
        "Uzbekistan",
        "Vanuatu",
        "Venezuela (Bolivarian Republic of)",
        "Viet Nam",
        "Yemen",
        "Zambia",
        "Zimbabwe",
      ]}},
      {"FormerName if applicable": {}},
    ]
  end
 
#  def "Street Address include apt lot etc AND PO Box  if applicable"
#    delivery_ballot_address || address
#  end
#  
#  def City_2
#    delivery_ballot_city || city
#  end
#
#  def State_2
#    delivery_ballot_state || home_state_name
#  end
#  
#  def ZIP_2
#    delivery_ballot_zip || zip
#  end
#
#  def "Street Address include apt lot etc AND PO Box  if applicable"=(value)
#    self.delivery_ballot_address= value
#  end
#  
#  def City_2=(value)
#    self.delivery_ballot_city= value
#  end
#
#  def State_2=(value)
#    self.delivery_ballot_state = value
#  end
#
#  def ZIP_2=(value)
#    self.delivery_ballot_zip = value
#  end
#
# 
#  def custom_form_field_validations
#    if self.has_mailing_address == "On"
#      custom_validates_presence_of("delivery_ballot_address")
#      custom_validates_presence_of("delivery_ballot_city")
#      custom_validates_presence_of("delivery_ballot_state")
#      custom_validates_presence_of("delivery_ballot_zip")
#    end
#
#    # make sure delivery is selected if reason ==3
#    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end