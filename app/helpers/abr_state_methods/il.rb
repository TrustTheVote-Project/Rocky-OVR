module AbrStateMethods::IL
  
  PDF_FIELDS = {
    "Applicants Name": {
      method: "full_name"
    },
    "Street Address": {
      method: "address"
    },
    "City State Zip": {
      method: "address_city_state_zip"
    },
    "County": {},
    "Date of Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Phone Number": {
      method: "phone"
    },
    "Email": {
      method: "email"
    },
    "ElectionPrecinct": {},
    "VOTERS OPTIONAL ADDRESS LINE 1": {
      method: "full_name"
    },
    "VOTERS OPTIONAL ADDRESS LINE 2": {},
    "VOTERS OPTIONAL ADDRESS LINE 3": {},
    "VOTERS OPTIONAL ADDRESS LINE 4": {},
    "delivery_address": { method: "delivery_full_address" },
  }
  EXTRA_FIELDS = ["has_mailing_address"]
   
  def form_field_items
    [
      {"County": {type: :select, required: true, include_blank: true, options: [
        "Adams",
        "Alexander",
        "Bond",
        "Boone",
        "Brown",
        "Bureau",
        "Calhoun",
        "Carroll",
        "Cass",
        "Champaign",
        "Christian",
        "Clark",
        "Clay",
        "Clinton",
        "Coles",
        "Cook",
        "Crawford",
        "Cumberland",
        "DeKalb",
        "De Witt",
        "Douglas",
        "DuPage",
        "Edgar",
        "Edwards",
        "Effingham",
        "Fayette",
        "Ford",
        "Franklin",
        "Fulton",
        "Gallatin",
        "Greene",
        "Grundy",
        "Hamilton",
        "Hancock",
        "Hardin",
        "Henderson",
        "Henry",
        "Iroquois",
        "Jackson",
        "Jasper",
        "Jefferson",
        "Jersey",
        "Jo Daviess",
        "Johnson",
        "Kane",
        "Kankakee",
        "Kendall",
        "Knox",
        "La Salle",
        "Lake",
        "Lawrence",
        "Lee",
        "Livingston",
        "Logan",
        "McDonough",
        "McHenry",
        "McLean",
        "Macon",
        "Macoupin",
        "Madison",
        "Marion",
        "Marshall",
        "Mason",
        "Massac",
        "Menard",
        "Mercer",
        "Monroe",
        "Montgomery",
        "Morgan",
        "Moultrie",
        "Ogle",
        "Peoria",
        "Perry",
        "Piatt",
        "Pike",
        "Pope",
        "Pulaski",
        "Putnam",
        "Randolph",
        "Richland",
        "Rock Island",
        "Saline",
        "Sangamon",
        "Schuyler",
        "Scott",
        "Shelby",
        "St. Clair",
        "Stark",
        "Stephenson",
        "Tazewell",
        "Union",
        "Vermilion",
        "Wabash",
        "Warren",
        "Washington",
        "Wayne",
        "White",
        "Whiteside",
        "Will",
        "Williamson",
        "Winnebago",
        "Woodford",
      ]}},
      {"ElectionPrecinct": {required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"VOTERS OPTIONAL ADDRESS LINE 2": {visible: "has_mailing_address"}},
      {"VOTERS OPTIONAL ADDRESS LINE 3": {visible: "has_mailing_address"}},
      {"VOTERS OPTIONAL ADDRESS LINE 4": {visible: "has_mailing_address"}},
    ]
  end
   
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end