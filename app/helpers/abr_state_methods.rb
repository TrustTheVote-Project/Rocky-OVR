module AbrStateMethods
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def pdf_fields
      @@pdf_fields ||= {}
      return @@pdf_fields
    end
    def add_pdf_fields(hash)
      hash.each do |name, opts|
        self.add_pdf_field(name, opts)
      end
    end
    def add_pdf_field(name, config_opts)
      opts = config_opts.dup
      method_name = opts[:method]
      if method_name.blank?
        opts[:virtual_attribute] = true
        opts[:method] ||= name.to_s.downcase.gsub(/\s/,'_')
        if opts[:method] =~ /\A\d/
          opts[:method] = "n_#{opts[:method]}"
        end
      end
      self.pdf_fields[name] = opts
      unless self.method_defined?(opts[:method])
        method_name = opts[:method]
        self.define_state_value_attribute(method_name)
      end
    end
    def define_state_value_attribute(method_name)
      define_method "#{method_name}" do
        value = instance_variable_get("@#{method_name}")
        if value.nil?
          value = self.abr_state_values.find_or_initialize_by(attribute_name: method_name).string_value
          instance_variable_set("@#{method_name}", value)
        end
        return value
      end
      define_method "#{method_name}=" do |value|
        v = self.abr_state_values.find_or_create_by(attribute_name: method_name)
        v.string_value = value
        v.save
        instance_variable_set("@#{method_name}", value)
      end
    end
  end
  
  def pdf_fields
    self.class.pdf_fields
  end
  
  def to_pdf_values
    v = {}
    pdf_fields.each do |name, opts|
      v[name] = opts[:value] || self.send(opts[:method])
    end
    v    
  end
  
  def permitted_attrs
    form_fields.collect {|fname, h| h[:method] }
  end
  
  def form_field_items
    []
  end
  
  def form_fields
    fields = []
    form_field_items.each do |item|
      field_name = nil
      field_opts = {}
      if item.is_a?(String)
        field_name = item        
      else
        field_name = item.keys.first.to_s
        field_opts = item.values.first
      end
      pdf_field = pdf_fields[field_name]
      method = pdf_field ? pdf_field[:method] : nil
      method ||= field_name
      fields.push([field_name, field_opts.merge({
          type: field_opts[:type] || :string,
          method: method
        })
      ])
    end
    return fields
  end
  
  def custom_validation_message(field_name, validation_type, default)
    I18n.t("states.custom.#{home_state_abbrev.downcase}.abr_form_fields.#{field_name}__#{validation_type}_message", default: default)
  end
  
  def custom_required_message(field_name)
    custom_validation_message(field_name, "required", I18n.t("required"))
  end
  
  def custom_too_short_message(field_name, count)
    custom_validation_message(field_name, "too_short", I18n.t("errors.messages.too_short", { count: count}))
  end

  def custom_too_long_message(field_name, count)
    custom_validation_message(field_name, "too_long", I18n.t("errors.messages.too_long", { count: count}))
  end

  def custom_wrong_length_message(field_name, count)
    custom_validation_message(field_name, "wrong_length", I18n.t("errors.messages.wrong_length", { count: count}))
  end

  def custom_format_message(field_name)
    custom_validation_message(field_name, "format", I18n.t("errors.messages.format"))
  end

  
  def validate_form_fields
    form_fields.each do |field_name, field_opts|
      value = self.send(field_opts[:method])
      if field_opts[:required]
        if value.blank?
          errors.add(field_opts[:method], custom_required_message(field_name))
        end
      end
      if field_opts[:min]
        if !value.blank? && value.length < field_opts[:min]
          errors.add(field_opts[:method], custom_too_short_message(field_name, field_opts[:min]))
        end
      end
      if field_opts[:max]
        if !value.blank? && value.length > field_opts[:max]
          errors.add(field_opts[:method], custom_too_long_message(field_name, field_opts[:max]))
        end
      end
      if field_opts[:length]
        if !value.blank? && value.length != field_opts[:length]
          errors.add(field_opts[:method], custom_wrong_length_message(field_name, field_opts[:length]))
        end
      end
      if field_opts[:regexp]
        if !value.blank? && !(value =~ field_opts[:regexp])
          errors.add(field_opts[:method], custom_format_message(field_name))
        end
      end
    end
    custom_form_field_validations
  end
  
  def custom_form_field_validations
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
        # puts e.message
        # pp e.backtrace
        # raise e
      end
    end
  end
  
end