class AbrStateValue < ActiveRecord::Base
  belongs_to :abr
  
  def value(type)
    case(type.to_s.downcase.to_sym) 
    when :boolean
      return self.boolean_value
    when :datetime
      return  self.datetime_value
    else  
      return self.string_value
    end
  end
  
  def set_value(v, type)
    case(type.to_s.downcase.to_sym) 
    when :boolean
      self.boolean_value = v
    when :datetime
      self.datetime_value = v
    else  
      self.string_value = v
    end
    #? self.save
  end
  
end
