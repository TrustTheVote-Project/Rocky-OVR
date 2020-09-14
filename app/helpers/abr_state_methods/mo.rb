module AbrStateMethods::MO
  
  PDF_FIELDS = {
    "do hereby request an absentee ballot for the": {
      method: "full_name"
    },
    "Election": {
      value: "11/03/2020"
    },
    "DOB": {
      method: "date_of_birth_mm_dd_yy"
    },
    #"SSN": {sensitive: true}, #last 4 ssn
    "Reason": { options: ["absence", "confidentiality", "employment", "incapacity", "incarceration", "religious", "COVID" ] },


    "Street Address": {
      method: "address"
    },
    "City State Zip Code": {
      method: "address_city_state_zip"
    },
    "Street Address or PO Box": {
      method: "mailing_address_1_if_different"
    },
    "City State Zip Code_2": {
      method: "mailing_address_2_if_different"      
    },
    "Include Area Code": {
      method: "phone"
    },
    "Email": {
      method:"email"
    }

    #Date
    #voter_signature
  }
  EXTRA_FIELDS = ["has_mailing_address", "mailing_address_1", "mailing_address_2"]
  
  def form_field_items
    [

      {"Reason": {type: :radio, required: true}},
      {"has_mailing_address": {type: :checkbox}}, 
      {"mailing_address_1": {visible: "has_mailing_address", required: :if_visible}},
      {"mailing_address_2": {visible: "has_mailing_address", required: :if_visible}},
    ]
  end
  
  def mailing_address_1_if_different
    self.has_mailing_address == "1" ? mailing_address_1 : address
  end
  def mailing_address_2_if_different
    self.has_mailing_address == "1" ? mailing_address_2 : address_city_state_zip
  end

  
  def custom_form_field_validations

  end
  
 
end