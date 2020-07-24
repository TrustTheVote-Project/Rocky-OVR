module AbrStateMethods
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def add_state_attribute(name, type)
      define_method "#{name}" do
        puts "defining method #{name}"
        self.abr_state_values.find_or_initialize_by(attribute_name: name).value(type)
      end
      define_method "#{name}=" do |value|
        v = self.abr_state_values.find_or_create_by(attribute_name: name)
        puts "set value #{v.inspect} #{value}, #{type}"
        v.set_value(value, type)
      end
    end
  end
  
  def home_state=(value)
    super(value)
    add_state_attributes
  end
  def home_state_id=(value)
    super(value)
    add_state_attributes
  end
  
  attr_reader :home_state_attributes_initialized
  def add_state_attributes
    @home_state_attributes_initialized ||= nil
    if home_state && !@home_state_attributes_initialized
      type = "AbrStateMethods::#{home_state_abbrev}"
      begin
        self.singleton_class.send(:include, Module.const_get(type))
        @home_state_attributes_initialized = true
      rescue Exception=>e
        raise e
      end
    end
  end
  
end