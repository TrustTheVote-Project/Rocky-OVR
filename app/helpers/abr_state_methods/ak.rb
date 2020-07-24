module AbrStateMethods::AK
  
  def self.included(klass)
    puts "HI #{klass}"
    klass.add_state_attribute :is_male, :boolean
  end
  
  def where_am_i
    return "Alaska"
  end
end