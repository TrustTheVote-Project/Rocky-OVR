module AbrStateMethods::IL::Madison
  
  PDF_FIELDS = {
    "address": {
      method: "address"
    },
    "birth_date": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "city": {
      method: "city"
    },
    "zip": {
      method: "zip"
    },
    "phone": {
      method: "phone"
    },
    "cell": {}, #TODO - I kinda think we don't need this and it can be left blank?
    "email": {
      method: "email"
    },
    "full_name": {
      method: "full_name"
    },
    "name_mail": {
      method: "mailing_name"
    },
    "address_mail": {},
    "city_mail": {},
    "state_mail": {},
    "zip_mail": {},
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
  def "mailing_name"
    #TODO- autofill with "full_name" if "has_mailing_address" is checked, otherwise leave blank
  end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"address_mail": {visible: "has_mailing_address"}},
      {"city_mail": {visible: "has_mailing_address", classes: "half"}},
      {"state_mail": {visible: "has_mailing_address", classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"zip_mail": {visible: "has_mailing_address", classes: "quarter last"}},
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end