module AbrStateMethods::IL::Macon
  
  PDF_FIELDS = {
    "NAME": {
      method: "full_name"
    },
    "BIRTH DATE": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "ADDRESS": {
      method: "address_line_1"
    },
    "APT": {
      method: "unit"
    },
    "CITY": {
      method: "city"
    },
    "STATE": {
      method: "home_state_abbrev"
    },
    "ZIP CODE": {
      method: "zip"
    },
    "CONTACT EMAIL ADDRESS": {
      method: "email"
    },
    "CONTACT PHONE NUMBER": {
      method: "phone"
    },
    "NAME_2": {
      method: "mailing_name"
    }, 
    "ADDRESS_2": {},
    "CITY_2": {},
    "STATE_2": {},
    "ZIP CODE_2": {},
    #"voter_signature": {}
  }
  EXTRA_FIELDS = ["has_mailing_address"]
  
   def mailing_name
     #TODO- autofill with "full_name" if "has_mailing_address" is checked, otherwise leave blank
    return full_name if self.has_mailing_address.to_s=='1'
  end
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"ADDRESS_2": {visible: "has_mailing_address", required: :if_visible}},
      {"CITY_2": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
      {"STATE_2": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}},
      {"ZIP CODE_2": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last"}},
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end