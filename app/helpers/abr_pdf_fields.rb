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
  
  def last_comma_first_name
    "#{last_name}, #{first_name} #{middle_name}".gsub(/\s+/, ' ').strip
  end
  
  def date_of_birth_mm_dd_yyyy
    self.date_of_birth&.strftime("%m/%d/%Y")
  end

  def date_of_birth_yyyy_mm_dd
    self.date_of_birth&.strftime("%Y-%m-%d")
  end
  
  def address
    "#{street_number} #{street_name}"
  end
  
  
end