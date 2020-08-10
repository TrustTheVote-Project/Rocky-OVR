module AbrStateMethods
  def self.included(klass)
    klass.extend AllClassMethods
  end

  module AllClassMethods
    def make_method_name(method_name, original_name=nil)
      method_name = original_name || method_name.to_s.downcase.gsub(/[^a-z\d_]/,'_')
      if method_name =~ /\A\d/
        method_name = "n_#{method_name}"
      end
      return method_name
    end
  end

  #module ClassMethods
    def pdf_fields
      @pdf_fields ||= {}
      return @pdf_fields
    end
    def sensitive_fields
      @sensitive_fields ||= []
      return @sensitive_fields
    end
    def add_pdf_fields(hash)
      hash.each do |name, opts|
        self.add_pdf_field(name.to_s, opts)
      end
    end
    
    def add_pdf_field(name, config_opts)
      opts = config_opts.dup
      method_name = opts[:method]
      if method_name.blank?
        opts[:virtual_attribute] = true
        opts[:method] = Abr.make_method_name(name, opts[:method])
      end
      self.pdf_fields[name] = opts
      unless self.respond_to?(opts[:method])
        method_name = opts[:method]
        self.define_state_value_attribute(method_name, sensitive: opts[:sensitive], checkbox_values: opts[:is_checkbox] ? opts[:options] : nil)
      end
    end
    def define_state_value_attribute(method_name, sensitive: false, checkbox_values: nil)
      if sensitive
        self.sensitive_fields.push(method_name)
      end
      define_singleton_method "#{method_name}" do
        value = instance_variable_get("@#{method_name}")
        if value.nil?
          value = self.abr_state_values.find_or_initialize_by(attribute_name: method_name).string_value
          instance_variable_set("@#{method_name}", value)
        end
        return value
      end
      define_singleton_method "#{method_name}=" do |value|
        # If this is a checkbox, assume 2 options are [false,true]
        if checkbox_values && checkbox_values.length == 2
          if [false, 0, "0", "false", "f", nil].include?(value)
            value = checkbox_values[0]
          else
            value = checkbox_values[1]
          end
        end
        v = self.abr_state_values.find_or_create_by(attribute_name: method_name)
        v.string_value = value
        v.save
        instance_variable_set("@#{method_name}", value)
      end
    end
  #end
  
  # def pdf_fields
  #   self.singleton_class.pdf_fields
  # rescue
  #   {}
  # end
  
  def redact_sensitive_data
    self.sensitive_fields.each do |method|
      puts "set #{method}"
      self.send("#{method}=", nil)
    end
  end
  
  def to_pdf_values
    v = {}
    pdf_fields.each do |name, opts|
      v[opts[:pdf_name] || name] = opts[:value] || self.send(opts[:method]) || opts[:default_value]
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
      if pdf_field && [:select, :radio].include?(field_opts[:type]) && field_opts[:options].blank?
        field_opts[:options] = pdf_field[:options]
      end
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

  def custom_validates_presence_of(f)
    errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
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
        klass = Module.const_get(type)
        self.singleton_class.send(:include, klass)
        self.add_pdf_fields(klass::PDF_FIELDS)
        klass::EXTRA_FIELDS.each do |f|
          self.define_state_value_attribute(f)
        end
        @home_state_attributes_initialized = true
      rescue Exception=>e
        # self.singleton_class.send(:extend, AllClassMethods) # Add default methods
        # puts e.message
        # pp e.backtrace
        raise e
      end
    end
  end
  
end