module AbrStateMethods
  def self.included(klass)
    klass.extend AllClassMethods
  end

  module AllClassMethods
    def make_method_name(method_name, original_name=nil, prefix_numbers: true)
      method_name = original_name || method_name.to_s.downcase.gsub(/[^a-z\d_]/,'_')
      if prefix_numbers && method_name =~ /\A\d/
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
        self.define_state_value_attribute(method_name, sensitive: opts[:sensitive], checkbox_values: opts[:is_checkbox] ? opts[:options] : nil, options: opts[:options])
        

      end
    end
    def define_state_value_attribute(method_name, sensitive: false, checkbox_values: nil, options: [])
      if method_name.is_a?(Hash)
        sensitive = method_name[:sensitive] || sensitive
        method_name = method_name[:name]
      end
      if sensitive
        self.sensitive_fields.push(method_name)
      end
      (options || []).each do |option_value|
        option_value_safe = Abr.make_method_name(option_value, prefix_numbers: false)
        define_singleton_method "#{method_name}_#{option_value_safe}" do
          return self.send(method_name) === option_value
        end
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
        v = self.abr_state_values.find_or_initialize_by(attribute_name: method_name)
        v.string_value = value
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
      value = opts[:value] || self.send(opts[:method]) || opts[:default_value]
      if opts[:options] && opts[:options].length == 2 && !opts[:options].include?(value) 
        if value == "1"
          value = opts[:options][1]
        else
          value = opts[:options][0]
        end
      end
      v[opts[:pdf_name] || name] = value
      
    end
    v    
  end
  
  def permitted_attrs
    form_fields.collect do |fname, h| 
      ms = [h[:method]]
      if h[:type] == :date
        ms << [h[:d], h[:m], h[:y]]
      end
      ms
    end.flatten
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
    I18n.t("states.custom.#{i18n_key}.abr_form_fields.#{field_name}__#{validation_type}_message", default: default)
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

  def custom_format_message_pattern(field_name)
    custom_validation_message(field_name, "format_pattern", I18n.t("errors.messages.format"))
  end

  def custom_validates_presence_of(f)
    errors.add(self.class.make_method_name(f), custom_required_message(f)) if self.send(self.class.make_method_name(f)).blank?
  end

  
  def date_field_value(field_opts)
    m_method = field_opts[:m] || "#{field_opts[:method]}_mm"
    d_method = field_opts[:d] || "#{field_opts[:method]}_dd"
    y_method = field_opts[:y] || "#{field_opts[:method]}_yyyy"
    
    y = self.send(y_method)
    m = self.send(m_method)
    d = self.send(d_method)
    return Date.parse("#{y}-#{m}-#{d}")
  rescue
    nil
  end
  
  def validate_form_fields
    form_fields.each do |field_name, field_opts|
      next if field_opts[:type] == :instructions
      value = field_opts[:type] == :date ? date_field_value(field_opts) : self.send(field_opts[:method])
      value = value.is_a?(String) ? value.strip : value
      if field_opts[:required]
        is_required = field_opts[:required] == true
        if field_opts[:required] == :if_visible && field_opts[:visible]
          method = field_opts[:visible]
          h_method = field_opts[:hidden]
          if (method.blank? || self.send(method) == "1") && (h_method.blank? || self.send(h_method) != "1")
            is_required = true
          end
        end
        if field_opts[:required] == :if_visible && field_opts[:hidden]
          method = field_opts[:hidden]
          if self.send(method) != "1"
            is_required = true
          end
        end
        if is_required && value.blank?
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
    if self.home_state && !@home_state_attributes_initialized
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
        raise e if Rails.env == "development"
      end
    end
  end

  def state_custom_javascript?
    if (!self.home_state_abbrev.blank?) 
      return File.exists?(File.join(Rails.root, 'app/assets/javascripts/abr_states/', "#{self.home_state_abbrev.to_s.downcase}.js"))
    end
  end
  
end