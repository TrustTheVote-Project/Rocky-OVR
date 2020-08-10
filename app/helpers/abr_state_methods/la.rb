module AbrStateMethods::LA
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
    "Mothers Maiden Name": {},
    "Residential Address": {}, #TODO- full address including city, state, zip
    "Options": {
      options: ["0", "1", "10", "11", "2", "3", "4", "5", "6", "7", "8", "9"]
    },
    "NumberStreetCityStateZip Code": {}, #mailing address
    #voter_signature
    #signature_date
    "submitted_by": {},
    "relationship_to_applicant": {},
    "Parish": {},
    "Ward_or_Precinct": {}, #this is optional - maybe we could delete it?
    "Day_Phone": {
      method: "phone"
    },
    "SSN_Last_4": {},
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "License_ID": {},
    "General_Election_Date": {
      value: "11/03/2020"
    },
    "absent_from": {},
    "absent_to": {},
    "receive_for_elections": {
      options: ["all_elections", "only_this_election"]
      value: "only_this_election" #TODO- only a static value if "options_0"
    },
    
  }
  
  EXTRA_FIELDS = ["hand_delivered_or_faxed", "has_mailing_address"] 
  
  
  def form_field_items
    [
      {"Parish": {type: :select, required: true, include_blank: true, options: [
        "Acadia",
        "Allen",
        "Ascension",
        "Assumption",
        "Avoyelles",
        "Beauregard",
        "Bienville",
        "Bossier",
        "Caddo",
        "Calcasieu",
        "Caldwell",
        "Cameron",
        "Catahoula",
        "Claiborne",
        "Concordia",
        "De Soto",
        "East Baton Rouge",
        "East Carroll",
        "East Feliciana",
        "Evangeline",
        "Franklin",
        "Grant",
        "Iberia",
        "Iberville",
        "Jackson",
        "Jefferson",
        "Jefferson Davis",
        "La Salle",
        "Lafayette",
        "Lafourche",
        "Lincoln",
        "Livingston",
        "Madison",
        "Morehouse",
        "Natchitoches",
        "Orleans",
        "Ouachita",
        "Plaquemines",
        "Pointe Coupee",
        "Rapides",
        "Red River",
        "Richland",
        "Sabine",
        "St. Bernard",
        "St. Charles",
        "St. Helena",
        "St. James",
        "St. John The Baptist",
        "St. Landry",
        "St. Martin",
        "St. Mary",
        "St. Tammany",
        "Tangipahoa",
        "Tensas",
        "Terrebonne",
        "Union",
        "Vermilion",
        "Vernon",
        "Washington",
        "Webster",
        "West Baton Rouge",
        "West Carroll",
        "West Feliciana",
        "Winn",
      ]}},
      {"Mothers Maiden Name": {required: true}},
      {"SSN_Last_4": {min:4, max: 4}},
      {"License_ID": {}},
      {"Options": {type: :radio, options: []}}, #TODO - grab options from above
      {"absent_from": {visible: "options_1"}},
      {"absent_to": {visible: "options_1"}},
      {"hand_delivered_or_faxed": {type: :checkbox}},
      {"submitted_by": {visible: "hand_delivered_or_faxed"}},
      {"relationship_to_applicant": {visible: "hand_delivered_or_faxed"}},
      {"has_mailing_address": {type: :checkbox}},
      {"NumberStreetCityStateZip Code": {visible: "has_mailing_address"}}
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