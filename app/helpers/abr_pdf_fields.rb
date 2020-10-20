module AbrPdfFields
  
  # "first_name"
  # "middle_name"
  # "last_name"
  # "name_suffix"
  # "street_number"
  # "street_name"
  # "street_line2"
  # "unit"
  # "city"
  # "home_state_name"
  # "home_state_abbrev"
  # "zip"
  # "email"
  # "phone"
  
  def full_name
    "#{first_name} #{middle_name} #{last_name} #{name_suffix}".gsub(/\s+/, ' ')
  end
  
  def middle_initial
    middle_name.blank? ? '' : middle_name[0]
  end
  
  def last_comma_first_name
    "#{last_name}, #{first_name} #{middle_name}".gsub(/\s+/, ' ').strip
  end
  
  def phone_and_email
    [phone, email].compact.join(", ")
  end

  def date_of_birth_mm
    self.date_of_birth&.strftime("%m")
  end
  def date_of_birth_dd
    self.date_of_birth&.strftime("%d")
  end
  def date_of_birth_yyyy
    self.date_of_birth&.strftime("%Y")
  end

  
  def date_of_birth_mm_dd_yyyy
    self.date_of_birth&.strftime("%m/%d/%Y")
  end

  def date_of_birth_mm_dd_yy
    self.date_of_birth&.strftime("%m/%d/%y")
  end

  def date_of_birth_yyyy_mm_dd
    self.date_of_birth&.strftime("%Y-%m-%d")
  end
  
  def address
    "#{street_number} #{street_name}" + (unit.blank? ? '' : ", #{unit}")
  end
  
  def address_line_1
    "#{street_number} #{street_name}"
  end
  
  def address_line_2
    unit.blank? ? nil : "#{unit}"
  end
  
  def address_city_state
    "#{city}, #{home_state_abbrev}"
  end
  
  def address_city_state_zip
    "#{city}, #{home_state_abbrev} #{zip}"
  end
  
  def full_address_1_line
    [address_line_1, address_line_2, address_city_state_zip].compact.join(", ")    
  end
  def full_address_2_lines
    "#{[address_line_1, address_line_2].compact.join(", ")}\n#{address_city_state_zip}"
  end
  def full_address_3_lines
    [address_line_1, address_line_2, address_city_state_zip].compact.join("\n")    
  end
  
  def delivery_full_address
    addr = state_registrar_office&.req_address
    return addr.blank? ? state_registrar_office&.address : addr
  end
  
  def delivery_addressee
    v = state_registrar_office&.req_address_to
    v.blank? ? state_registrar_office&.vr_address_to : v
  end
  
  def delivery_street1
    v = state_registrar_office&.req_street1
    v.blank? ? state_registrar_office&.vr_street1 : v
  end

  def delivery_street2
    v = state_registrar_office&.req_street2
    v.blank? ? state_registrar_office&.vr_street2 : v
  end

  def delivery_city
    v = state_registrar_office&.req_city
    v.blank? ? state_registrar_office&.vr_city : v
  end

  def delivery_state
    v = state_registrar_office&.req_state
    v.blank? ? state_registrar_office&.vr_state : v
  end

  def delivery_zip
    v = state_registrar_office&.req_zip
    v.blank? ? state_registrar_office&.vr_zip : v
  end
  
  def delivery_city_state_zip
    "#{delivery_city}, #{delivery_state} #{delivery_zip}"
  end
  
  def pdf_cover_fields
    [
      "SUBMIT YOUR COMPLETED SIGNED FORM TO",
      "Request Deadline",
      "Reminders for your state",
    ]
  end

  def submit_your_completed_signed_form_to
    "\n#{state_registrar_address_newlines}"
  end
 
  def request_deadline 
    "\n#{self.cover_state_deadline}"
  end

  def reminders_for_your_state 
    "#{self.cover_state_reminders}"
  end


  def state_registrar_address_newlines
    state_registrar_address.gsub(/<br>/,"\n")
  end

  def cover_state_deadline
    I18n.t("states.custom.#{i18n_key}.abr.request_deadline", default: '')
  end

  def abr_status_check_url
    if (home_state_abbrev)
      RockyConf.absentee_states[home_state_abbrev]&.abr_status_check_url
    end
  end


  def  cover_state_reminders
    reminders="";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.abr_status_check_intro", default: "")
    reminders+="\n\n";
    reminders+=  abr_status_check_url.to_s()
    reminders+="\n\n";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.state_reminder_1", default: "")
    reminders+="\n";
    reminders+= I18n.t("states.custom.#{i18n_key}.abr.state_reminder_2", default: "")

  end
    
    
  
  
  
end