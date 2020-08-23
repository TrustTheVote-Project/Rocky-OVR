module AbrStateMethods::IL::Mcdonough
  
  PDF_FIELDS = {
    "DATE OF BIRTH": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Name": {
      method: "full_name"
    },
    "party": { 
      options: ["DEMOCRATIC", "Off", "REPUBLICAN", "other"],
      value: "Off" 
    },
    #"date": {},
    "mail_address1": {},
    "mail_address2": {},
    "mail_address3": {},
    "mail_address4": {},
    "residence_address2": {
      method: "address_line_2"
    },
    "residence_address1": {
      method: "address_line_1"
    },
    "residence_address3": {
      method: "address_city_state_zip"
    },
    #"ID": {},
    #"ballot_style": {}
    #"precinct": {}
    #"voters_consecutive_number": {}
    "printed_name": {
      method: "full_name"
    },
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"mail_address1": {visible: "has_mailing_address"}},
      {"mail_address2": {visible: "has_mailing_address"}},
      {"mail_address3": {visible: "has_mailing_address"}},
      {"mail_address4": {visible: "has_mailing_address"}},
    ]
  end
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end