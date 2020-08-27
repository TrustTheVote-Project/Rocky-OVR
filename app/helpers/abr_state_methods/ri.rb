module AbrStateMethods::RI
  
  PDF_FIELDS = {
    "Text Field 4": {
      method: "full_name"
    },
    "Text Field 11": {},
    "Text Field 5": {
      method: "address"
    },
    "Text Field 12": {
      method: 'override_address'
    },
    "Text Field 6": {
      method: "city"
    },
    "Text Field 7": {
      method: "zip"
    },
    "Text Field 8": {
      method: "date_of_birth_mm_dd_yyyy"
    },
    "Text Field 9": {
      method: "phone"
    },
    "Text Field 14":{
      method: 'override_city'
    },
    "Text Field 15": {
      method: 'override_state'
    },
    "Text Field 16": {
      method: 'override_zip'
    },
    "Text Field 10": {
      method: "email"
    },
    "Text Field 18": {
      method: "email_conditional"
    }, #TODO - if "eligibility_military" is selected, autofill with email, #ToDone
    "eligibility": { options: ["absent", "confined", "incapacitated", "military"] },
  }
  EXTRA_FIELDS = ["has_mailing_address", "mail_address", "mail_city", "mail_state", "mail_zip"]
  # e.g.
  # EXTRA_FIELDS = ["has_mailing_address", "identification"]
  
  # def whatever_it_is_you_came_up_with
  #   # TODO when blah is selected it should be "abc" and otherwise left blank
  # end
  
  
  def form_field_items
    [
      {"eligibility": {type: :radio, required: true}},
      # TODO when "confined" is selected, make sure field 11,12,13,14,15,16 get populated by either the residence address or a user-entered mailing address
      # TODONE fields 11, 13 are N/A
      {"has_mailing_address": {type: :checkbox}},
      {"Text Field 11": {visible: "has_mailing_address"}},
      {"mail_address": {visible: "has_mailing_address", required: :if_visible }},
      {"mail_city": {visible: "has_mailing_address", required: :if_visible, classes: "half"}},
      {"mail_state": {visible: "has_mailing_address", required: :if_visible, classes: "quarter", type: :select, options: GeoState.collection_for_select, include_blank: true}}, #TODO -- this should just be abbreviations
      {"mail_zip": {visible: "has_mailing_address", required: :if_visible, classes: "quarter last"}},
      
    ]
  end
  
  def email_conditional
    if(self.eligibility == "military")
      return self.email
    end
  end

  def override_field_value(override, fieldname1, fieldname2) 
    if (override) 
      #return self.send("#{self.class.make_method_name(fieldname2)}") 
      return self.send(fieldname2) 
    else 
      #return self.send("#{self.class.make_method_name(fieldname1)}")
      return self.send(fieldname1)
    end
  end

  def override_mailing_address_field (fieldname1, fieldname2)
      return override_field_value((self.has_mailing_address.to_s == "1"), fieldname1, fieldname2)
  end

  def conditional_set_and_override_mailing_address_field (fieldname1, fieldname2) 
    if eligibility.to_s=="confined" 
      return override_mailing_address_field(fieldname1, fieldname2)
    end
  end


  
  def override_address
    return conditional_set_and_override_mailing_address_field("address", "mail_address")
  end


  def override_city
    return conditional_set_and_override_mailing_address_field("city", "mail_city")
  end

  def override_state
    return conditional_set_and_override_mailing_address_field("home_state_abbrev", "mail_state")
  end 

  def override_zip
    return conditional_set_and_override_mailing_address_field("zip", "mail_zip")
  end

  
  def custom_form_field_validations

  end
  
 
end