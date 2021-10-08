module AbrStateMethods::LA
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
    "Mothers Maiden Name": { sensitive: true },
    "Residential Address": {
      method: "full_address_1_line"
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
    "on on": { #Primary election date
      value: "11/13/2021"
    },
    "General_Election_Date": {
      value: "12/10/2021"
    },
    "absent_from": { method: "absent_from_date" },
    "absent_to": { method: "absent_to_date" },
    "receive_for_one_elections": {
      options: ["Off", "On"],
      value: "Off"
    },
    "receive_for_all_elections": {
      options: ["Off", "On"],
      value: "On"
    },

    "already_approved": {
      options: ["Off", "On"],
      method: "reason_already"
    },
    "submitting_proof": {
      options: ["Off", "On"],
      method: "reason_submitting"
    },
    "homebound_submitting_proof": {
      options: ["Off", "On"],
      method: "reason_homebound_submitting"
    },

    "receipt_type_email": {
      options: ["Off", "On"],
      method: "receipt_type_email"
    },
    "receipt_type_mail": {
      options: ["Off", "On"],
      method: "receipt_type_mail"
    },
    "receipt_type_fax": {
      options: ["Off", "On"],
      method: "receipt_type_fax"
    },


    "email": {
      method: :email_if_email_receipt
    },
    "mailing_1": {
      method: :mailing_1_if_mail_receipt
    },
    "mailing_2": {
      method: :mailing_2_if_mail_receipt
    },
    "fax": {
      method: :fax_if_fax_receipt
    },
    #voter_signature
    #signature_date
    
  }
  
  EXTRA_FIELDS = ["hand_delivered_or_faxed", "has_mailing_address","dln_soft_validation","reason","receipt_type", "mailing_address_1", "mailing_address_2", "fax_number"] 
  
  def reason_already
    if self.reason === "already"
      return "On"
    end
    return "Off"
  end
  def reason_submitting
    if self.reason === "submitting"
      return "On"
    end
    return "Off"
  end
  def reason_homebound_submitting
    if self.reason === "homebound_submitting"
      return "On"
    end
    return "Off"
  end

  def email_if_email_receipt
    if self.receipt_type.to_s === "email"
      return self.email
    end
    return ''
  end
  def mailing_1_if_mail_receipt
    if self.receipt_type.to_s === "mail"
      return self.has_mailing_address == "1"  ? self.mailing_address_1 : self.address
    end
    return ''
  end
  def mailing_2_if_mail_receipt
    if self.receipt_type.to_s === "mail"
      return self.has_mailing_address == "1" ? self.mailing_address_2 : self.address_city_state_zip
    end
    return ''
  end
  def fax_if_fax_receipt
    if self.receipt_type.to_s === "fax"
      return self.fax_number
    end
    return ''
  end

  def receipt_type_email
    if self.receipt_type.to_s === "email"
      return "On"
    end
    return "Off"
  end
  def receipt_type_mail
    if self.receipt_type.to_s === "mail"
      return "On"
    end
    return "Off"
  end
  def receipt_type_fax
    if self.receipt_type.to_s === "fax"
      return "On"
    end
    return "Off"
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
      {"reason": {type: :radio, options: ["already", "submitting", "homebound_submitting"]}},

      {"receipt_type": {type: :radio, options: ["email", "mail", "fax"]}},
      {"fax_number": {visible: "receipt_type_fax"}},
      {"has_mailing_address": {type: :checkbox}},
      {"mailing_address_1": {visible: "has_mailing_address", required: :if_visible}},
      {"mailing_address_2": {visible: "has_mailing_address", required: :if_visible}},
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
  

  
  
  
 
end
