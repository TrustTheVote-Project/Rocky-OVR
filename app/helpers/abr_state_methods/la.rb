module AbrStateMethods::LA
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
    "Mothers Maiden Name": { sensitive: true },
    "Residential Address": {
      method: "full_address_1_line"
    },
    "Options": {
      options: ["0", "1", "10", "11", "2", "3", "4", "5", "6", "7", "8", "9"]
    },
    "NumberStreetCityStateZip Code": {}, #mailing address
    "submitted_by": {},
    "relationship_to_applicant": {},
    "Parish": {},
    "Ward_or_Precinct": {}, #this is optional - maybe we could delete it?
    "Day_Phone": {
      method: "phone"
    },
    "SSN_Last_4": { sensitive: true },
    "Date_of_Birth": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "License_ID": { sensitive: true },
    "General_Election_Date": {
      value: "11/03/2020"
    },
    "absent_from": { method: "absent_from_date" },
    "absent_to": { method: "absent_to_date" },
    "receive_for_elections": {
      #options: ["all_elections", "only_this_election"],
      #value: "only_this_election" - only a static value if "options_0"
      method: 'only_this_election_if_option_0'
    },
    #voter_signature
    #signature_date
    
  }
  
  EXTRA_FIELDS = ["hand_delivered_or_faxed", "has_mailing_address", "absent_from", "absent_to", "absent_from_mm", "absent_from_dd", "absent_from_yyyy", "absent_to_mm", "absent_to_dd", "absent_to_yyyy","dln_soft_validation",] 
  
  def only_this_election_if_option_0
    if self.options.to_s =='0'
      return 'only_this_election'
    else
      return 'Off'
    end
  end

  
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
      {"id_instructions": {type: :instructions}},
      {"SSN_Last_4": {min:4, max: 4}},
      {"License_ID": {ui_regexp:"^0[0-9]{7}$"}},
      {"Options": {type: :radio, required: true}}, 
      {"absent_from_date": {visible: "options_1", required: "show_star", type: :date, m: "absent_from_mm", d: "absent_from_dd", y: "absent_from_yyyy"}},
      {"absent_to_date": {visible: "options_1", required: "show_star", type: :date, m: "absent_to_mm", d: "absent_to_dd", y: "absent_to_yyyy"}},
      {"hand_delivered_or_faxed": {type: :checkbox}},
      {"submitted_by": {classes: "indent", visible: "hand_delivered_or_faxed", required: :if_visible}},
      {"relationship_to_applicant": {classes: "indent", visible: "hand_delivered_or_faxed", required: :if_visible}},
      {"has_mailing_address": {type: :checkbox}},
      {"NumberStreetCityStateZip Code": {visible: "has_mailing_address", required: :if_visible}},
      {"dln_soft_validation": {type: :hidden}},
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
  
  def absent_from_date
    dates = [absent_from_mm, absent_from_dd, absent_from_yyyy].collect {|d| d.blank? ? nil : d}.compact
    if dates.length == 3
      dates.join("/")
    else
      nil
    end
  end
  
  def absent_to_date
    dates = [absent_to_mm, absent_to_dd, absent_to_yyyy].collect {|d| d.blank? ? nil : d}.compact
    if dates.length == 3
      dates.join("/")
    else
      nil
    end
  end
  
  def custom_form_field_validations
    if self.options == "1"
      custom_validates_presence_of("absent_from_date")
      custom_validates_presence_of("absent_to_date")
    end
    if self.hand_delivered_or_faxed.to_s == "1"
      custom_validates_presence_of("submitted_by")
      custom_validates_presence_of("relationship_to_applicant")      
    end
    if self.has_mailing_address.to_s == "1"
      custom_validates_presence_of("NumberStreetCityStateZip Code")
    end
  end
  
  # "only_this_election" - only a static value if "options_0"
  def receive_for_elections
    if self.options == "0"
      return "only_this_election"
    end
  end
  
 
end
