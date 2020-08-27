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
    "#{first_name} #{middle_name} #{last_name}".gsub(/\s+/, ' ')
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
    return (addr.blank? ? state_registrar_office&.address : addr).gsub("\n", "&#x10;")
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
  
    
    
  
  
  
end