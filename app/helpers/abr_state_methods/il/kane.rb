module AbrStateMethods::IL::Kane
  
  PDF_FIELDS = {
    "Name": {
      method: "full_name"
    },
    "Street": {
      method: "address"
    },
    "CityZip": {}, #TODO - make this work
    "Birth Date": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Telephone": {
      method: "phone"
    },
    "Name_2": {
      method: "mailing_name"
    },
    "Street_2": {},
    "CityStateZip": {},
    #"Date": {}
    "residence_date": {},
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def "mailing_name"
    #TODO- autofill with "full_name" if "has_mailing_address" is checked, otherwise leave blank
  end
  
  
  def form_field_items
    [
      {"residence_date": {required: true}},
      {"has_mailing_address": {type: :checkbox}},
      {"Street_2": {visible: "has_mailing_address"}},
      {"CityStateZip": {visible: "has_mailing_address"}},
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end