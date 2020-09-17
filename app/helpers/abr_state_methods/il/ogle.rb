module AbrStateMethods::IL::Ogle
  
  PDF_FIELDS = {
    #"Date": {},
    "20": {
      value: "20"
    },
    "Name and Address where Registered": {
      method: "full_name_and_address"
    }, #TODO - need full name AND full address, #ToDone
    "Phone #": {
      method: "phone"
    },
    "e-mail address": {
      method: "email"
    },
    "Address to mail ballot if different than above": {},
    #"voter_signature": {},
    "voter_name": {
      method: "full_name"
    },
  }

  def full_name_and_address
    "#{full_name}\n#{full_address_3_lines}"
  end

  EXTRA_FIELDS = ["has_mailing_address"]
  
  
  def form_field_items
    [
      {"has_mailing_address": {type: :checkbox}},
      {"Address to mail ballot if different than above": {visible: "has_mailing_address", required: :if_visible}},
    ]
  end
  
  def custom_form_field_validations
    # make sure delivery is selected if reason ==3
    # make sure fax is provided if faxtype is selected for delivery
  end
  
 
end