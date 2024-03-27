module DateOfBirthMethods
  def date_of_birth=(string_value)
    dob = nil
    if string_value.is_a?(String)
      if matches = string_value.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{4})\z/)
        m,d,y = matches.captures
        dob = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      elsif matches = string_value.match(/\A(\d{4})\D+(\d{1,2})\D+(\d{1,2})\z/)
        y,m,d = matches.captures
        dob = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      else
        dob = string_value
      end
    else
      dob = string_value
    end
    write_attribute(:date_of_birth, dob)
  end

  def date_of_birth_day
    date_of_birth&.day || @date_of_birth_day
  end
  def date_of_birth_day=(string_value)
    @date_of_birth_day= string_value
    set_date_of_birth_from_parts
  end
  def date_of_birth_month
    date_of_birth&.month || @date_of_birth_month
  end
  def date_of_birth_month=(string_value)
    @date_of_birth_month= string_value
    set_date_of_birth_from_parts
  end
  def date_of_birth_year
    date_of_birth&.year || @date_of_birth_year
  end    
  def date_of_birth_year=(string_value)
    @date_of_birth_year= string_value
    set_date_of_birth_from_parts
  end
  
  def date_of_birth_from_parts
    "%02d-%02d-%d" % [@date_of_birth_month, @date_of_birth_day, @date_of_birth_year].collect(&:to_i)
  end
  
  def date_of_birth_parts
    [@date_of_birth_month, @date_of_birth_day, @date_of_birth_year]
  end
  
  def set_date_of_birth_from_parts
    if date_of_birth_parts.collect{|p| p.blank? ? nil : p }.compact.length == 3
      dmy_string = date_of_birth_from_parts 
      if matches = dmy_string.to_s.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{1,4})\z/)
        m,d,y = matches.captures
        begin
          self.date_of_birth = Date.civil(y.to_i, m.to_i, d.to_i) 
        rescue
        end
      end
    else
      self.date_of_birth = nil
    end
  end
  
  def form_date_of_birth
    if @raw_date_of_birth
      @raw_date_of_birth
    elsif date_of_birth
      "%02d-%02d-%d" % [date_of_birth.month, date_of_birth.mday, date_of_birth.year]
    else
      nil
    end
  end

  def validate_minimum_age
    if date_of_birth.present? && (Date.today - date_of_birth) < 13.years
      errors.add(:date_of_birth, :way_too_young)
    end
  end
  
  # TODO: remove duplicate from RegistrantAbrMethods
  def validate_date_of_birth_age
    if date_of_birth.present?
      validate_minimum_age
      return if errors[:date_of_birth].present? # Skip other validations if age is invalid
      if date_of_birth < Date.parse("1900-01-01")
        errors.add(:date_of_birth, :too_old)
      elsif date_of_birth > Date.today
        errors.add(:date_of_birth, :future)
      end
    end
  end


  # TODO: remove duplicate from RegistrantAbrMethods
  def validate_date_of_birth
    if date_of_birth_before_type_cast.is_a?(Date) || date_of_birth_before_type_cast.is_a?(Time)
      validate_date_of_birth_age
      return
    end
    if date_of_birth_before_type_cast.blank?
      if date_of_birth_parts.compact.length == 3
        errors.add(:date_of_birth, :invalid)
      else
        errors.add(:date_of_birth, :blank)
      end
    else
      @raw_date_of_birth = date_of_birth_before_type_cast
      date = nil
      if matches = date_of_birth_before_type_cast.to_s.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{4})\z/)
        m,d,y = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      elsif matches = date_of_birth_before_type_cast.to_s.match(/\A(\d{4})\D+(\d{1,2})\D+(\d{1,2})\z/)
        y,m,d = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      end
      if date
        @raw_date_of_birth = nil
        self[:date_of_birth] = date
        validate_date_of_birth_age
      else
        errors.add(:date_of_birth, :format)
      end
    end
  end
end