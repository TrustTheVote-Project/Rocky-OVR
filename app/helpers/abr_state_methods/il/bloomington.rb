module AbrStateMethods::IL::Bloomington
  
  PDF_FIELDS = {
    "name": {
      method: "full_name"
    },
    "residence2": {
      method: "address_city_state_zip"
    },
    "Birthdate": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "residence1": {
      method: "address"
    },
    "mail_address": {},
    "mail_city": {},
    "mail_apt_number": {},
    "mail_state": {},
    "mail_zip": {},
    "Applicant_printed_name": {
      method: "full_name"
    },
    #"signed_day": {}
    #"signed_month": {}
    #"signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"mail_address": {visible: "has_mailing_address", classes: "three-quarter"}},
      {"mail_apt_number": {visible: "has_mailing_address", classes: "quarter last"}},
      {"mail_city": {visible: "has_mailing_address", classes: "half"}},
      {"mail_state": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"mail_zip": {visible: "has_mailing_address", classes: "quarter last"}},
    ]
  end
  
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end