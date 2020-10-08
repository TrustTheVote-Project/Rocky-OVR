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
  
end