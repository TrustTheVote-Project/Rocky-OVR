module ApplicationHelper

  # flash_messages
  # use to display specified flash messages
  # defaults to standard set: [:success, :message, :warning]
  # example:
  #   <%= flash_messages %>
  # example with other keys:
  #   <%= flash_messages :notice, :violation %>
  # renders like:
  #  <ul class="flash">
  #   <li class="flash-success">Positive - successful action</li>
  #   <li class="flash-message">Neutral - reminders, status</li>
  #   <li class="flash-warning">Negative - error, unsuccessful action</li>
  #  </ul>
  def flash_messages(*keys)
    keys = [:success, :message, :warning] if keys.empty?
    messages = []
    keys.each do |key|
      messages << content_tag(:li, flash[key], :class => "flash-#{key}").html_safe if flash[key]
    end
    if messages.empty?
       content_tag(:div, "", :class => "flash").html_safe
    else
      content_tag(:ul, messages.join("\n").html_safe, :class => "flash").html_safe
    end
  end

  def partner_locale_options(partner, locale, source)
    opts = {}
    opts[:partner] = partner unless partner == Partner::DEFAULT_ID
    opts[:locale]  = locale  unless locale == "en"
    opts[:source]  = source  unless source.blank?
    opts
  end

  def preview_partner_css(partner, registrant, include_mobile)
    stylesheets = []
    if !partner.replace_system_css?(:preview)
      stylesheets << 'application'
      if registrant.use_state_flow? && !registrant.skip_state_flow?
        if @use_newui2020
          stylesheets << 'registration3'
        else
          stylesheets << 'registration2'
        end
        stylesheets << "states/#{registrant.home_state_abbrev.downcase}"        
      else
        newregcss = @use_newui2020 ? 'registration3' : 'registration2'
        stylesheets << (registrant && !registrant.use_short_form? ? 'registration' : newregcss)
      end
    end
    stylesheets += registrant_css
    if registrant && !registrant.use_short_form?
      stylesheets << partner.partner_css_url(:preview)
      stylesheets << partner.partner2_mobile_css_url(:preview) if include_mobile
    elsif partner.partner3_css_present(:preview)
      stylesheets << partner.partner3_css_url(:preview)
    else
      stylesheets << partner.partner2_css_url(:preview)
      stylesheets << partner.partner2_mobile_css_url(:preview) if include_mobile
    end
    return stylesheets.compact
  end

  def partner_css(partner = @partner, registrant=@registrant || @abr, include_mobile = @use_mobile_ui)
    if params.has_key?(:preview_custom_assets) || registrant.try(:is_fake)
      return preview_partner_css(partner, registrant, include_mobile)
    end
    wl = partner && partner.whitelabeled?
    stylesheets = []
    if !partner || !partner.replace_system_css?
      if registrant && registrant.use_state_flow? && !registrant.skip_state_flow? 
        stylesheets << "application"
        stylesheets << (@use_newui2020 ? 'registration3' : 'registration2')
        stylesheets << "states/#{registrant.home_state_abbrev.downcase}"
      elsif partner && registrant && !registrant.use_short_form?
        stylesheets << (wl && partner.application_css_present? ? partner.application_css_url : "application")
        stylesheets << (wl && partner.registration_css_present? ? partner.registration_css_url : "registration")
      else
        # Partners can't upload reg2 - just part2 and either keep the default reg2 or mark as reaplce_system_css
        stylesheets << "application"
        stylesheets << (@use_newui2020 ? 'registration3' : 'registration2')
      end
    end
    # event with replace_system_css, keep the locale specific ones
    stylesheets += registrant_css
    if partner && registrant && !registrant.use_short_form?
      stylesheets << partner.partner_css_url if wl && partner.partner_css_present?
    else
      if partner.partner3_css_present? && wl
        stylesheets << partner.partner3_css_url
      else
        stylesheets << partner.partner2_css_url if wl && partner.partner2_css_present?
        stylesheets << partner.partner2_mobile_css_url if include_mobile && wl && partner.partner2_mobile_css_present?      
      end
    end
    stylesheets
  end
  
  def registrant_css(registrant = @registrant || @abr, locale = @locale)
    stylesheets = []
    locale ||= registrant ? registrant.locale : nil
    if !locale.nil?
      stylesheets << "locales/#{locale}" if Translation.has_css?(locale)
    end
    stylesheets
  end
  
  def nvra_css(registrant = @registrant, locale = @locale)
    stylesheets = []
    locale ||= registrant ? registrant.locale : nil
    if !locale.nil?
      stylesheets << "nvra/locales/#{locale}" if Translation.has_nvra_css?(locale)
    end
    stylesheets
  end

  def yes_no_options
    [['', nil], ['Yes', true], ['No', false]]
  end

  def octothorpe(unit)
    unit =~ /\A\d+\z/ ? "##{unit}" : unit
  end

  def progress_indicator(num_steps)
    (1..((num_steps || 5).to_i)).map do |step_index|
      progress = case step_index <=> (controller.current_step || 1).to_i
      when -1 then "progress-done"
      when 0 then "progress-current"
      else "progress-todo"
      end
      step_value = progress == 'progress-done' ? "&#x2713;".html_safe : step_index
      content_tag :li, step_value, :class => progress
    end.join
  end

  def tooltip_tag(tooltip_id, content = nil)
    content ||= t("txt.registration.tooltips.#{tooltip_id}")
    image_tag 'buttons/help_icon.png', :mouseover => 'buttons/help_icon_over.png', :alt => t('txt.button.help'),
      :class => 'tooltip', :id => "tooltip-#{tooltip_id}",
      :title => content
  end
  
  def required_message_for(object, field_name)
    I18n.t("activerecord.errors.models.#{object.class.name.underscore}.attributes.#{field_name}.blank", default: I18n.t("activerecord.errors.models.#{object.class.name.underscore}.blank"), locale: object.locale)
  end

  def require_accept_message_for(object, field_name)
    I18n.t("activerecord.errors.models.#{object.class.name.underscore}.attributes.#{field_name}.accepted", default: I18n.t("activerecord.errors.models.#{object.class.name.underscore}.accepted"), locale: object.locale)
  end

  
  def field_li(form, field, options={})
    required = options[:required]==true ? "<span class='required'>*<span class='required--text' style='display:none;'>#{I18n.t('required')}</span></span>" : ''
    field_name = options[:field_name] || field
    instructions = options[:instructions]
    instructions_html = instructions.blank? ? nil : "<p class='instructions'>#{instructions}</p>"
    tooltip = options[:skip_tooltip] ? "" : content_tag(:div, tooltip_tag(field_name, options[:tooltip_content]).html_safe, class: 'tooltip')
    label = ''
    if @use_newui2020 
      label = content_tag(:h3, (form.send(:label, field_name, options[:label_options]) + required.html_safe + tooltip.html_safe).html_safe)
    else
      label = content_tag(:h3, (form.send(:label, field_name, options[:label_options]) + required.html_safe).html_safe)
    end
    error = "<span class='error'>#{form.object.errors[field_name].join("\n").html_safe}</span>".html_safe
    field_html = nil
    if options[:required]
      options[:field_options] ||= {}
      options[:field_options][:required] = options[:required]
      options[:field_options][:required_message] = options[:required_message]
    end
    if options[:select_options]
      field_html = select_div(form, field, options[:select_options], options[:field_options])
    elsif options[:radio_options]
      radio_label = options[:label_options] || form.object.class.human_attribute_name(field)
      label = content_tag(:h3, (radio_label.html_safe + required.html_safe).html_safe).html_safe
      field_html = radio_div(form, field, options[:radio_options], options[:field_options])
    else
      field_html = field_div(form, field, options[:field_options])
    end
    if @use_newui2020 
      content_tag(:li, "#{label}#{instructions_html}#{field_html.html_safe}#{error}".html_safe, options[:li_options])
    else
      content_tag(:li, "#{label}#{instructions_html}#{field_html.html_safe}#{tooltip}#{error}".html_safe, options[:li_options])
    end
  end

  def field_div(form, field, options={})
    options ||= {}
    kind = options.delete(:kind) || "text"
    selector = "#{kind}_field"
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    class_name = [options.delete(:class), has_error].compact.join(' ')
    if req_type = options.delete(:required)
      options[:data] ||= {}
      if req_type == :conditional
        options[:data]["client-conditional-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      else
        options[:data]["client-validation-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      end
    end    
    if options.delete(:require_accept)
      options[:data] ||= {}
      options[:data]["client-validation-require-accept".to_sym] = require_accept_message_for(form.object, field)
    end
    content_tag(:div, form.send( selector, field, {:size => nil}.merge(options) ).html_safe, :class => class_name).html_safe
  end

  def select_div(form, field, contents, options={})
    options ||= {}
    html_options = {}
    if req_type = options.delete(:required)
      html_options[:data] ||= {}
      if req_type == :conditional
        html_options[:data]["client-conditional-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      else
        html_options[:data]["client-validation-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      end
    end
    if options.delete(:require_accept)
      options[:data] ||= {}
      options[:data]["client-validation-require-accept".to_sym] = require_accept_message_for(form.object, field)
    end
    
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    content_tag(:div, form.select(field, contents, options, html_options), :class => has_error)
  end
  
  def radio_div(form, field, radio_options, options={})
    options ||= {}
    html_options = {}
    if req_type = options.delete(:required)
      html_options[:data] ||= {}
      if req_type == :conditional
        html_options[:data]["client-conditional-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      else
        html_options[:data]["client-validation-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      end
    end
    
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    radio_buttons = radio_options.collect do |text, value|
      radio = form.radio_button(field, value).html_safe
      form.label("#{field}_#{Abr.make_method_name(value, prefix_numbers: false)}", "#{radio} #{text}".html_safe).html_safe
    end.join("\n").html_safe
    content_tag(:div, radio_buttons, html_options.merge(:class => "#{has_error} radio-buttons"))
  end

  def checkbox_block_selector(form, field, label, tooltip_key = nil, options={})
    options ||= {}
    html_options = {}
    required = ""
    if req_type = options.delete(:required)
      required = "<span class='required'>*<span class='required--text' style='display:none;'>#{I18n.t('required')}</span></span>"
      html_options[:data] ||= {}
      if req_type == :conditional
        #html_options[:data]["client-conditional-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      else
        #html_options[:data]["client-validation-required".to_sym] = options[:required_message] || required_message_for(form.object, field)
      end
    end
    tooltip = tooltip_key ? tooltip_tag(tooltip_key) : ""
    has_error = !form.object.errors[field].empty? ? "has_error" : nil
    error = "<span class='error'>#{form.object.errors[field].join("\n").html_safe}</span>".html_safe
    
    instructions = options[:instructions]
    instructions_html = instructions.blank? ? nil : "<p class='instructions'>#{instructions}</p>"
    label = content_tag(:h3, label.html_safe + required.html_safe + tooltip.html_safe).html_safe
    hidden_field_value = case form.object.send(field)
      when nil
        ""
      when true, "1"
        "1"
      when false, "0", ""
        "0"
      else
        ""
    end
      
    hidden_field = form.hidden_field(field, class: "block-selector__input", value: hidden_field_value)
    yes_selected = !!form.object.send(field)
    yes_block = "<span class=\"block-selector__button block-selector__button--yes #{"block-selector__button--selected" if yes_selected } \">#{I18n.t('yes')}</span>"
    no_block = "<span class=\"block-selector__button block-selector__button--no  #{"block-selector__button--selected" unless  yes_selected }\">#{I18n.t('no')}</span>"
    children = [
      label,
      hidden_field,
      "<div class='block-selector__yes-no'>#{yes_block} #{no_block}</div>".html_safe,
      error
    ].join("\n").html_safe
    content_tag(:div, children, html_options.merge(class: "#{has_error} block-selector__checkbox-field"))
  end

  def rollover_button(name, text, button_options={})
    button_options[:id] ||= "registrant_submit"
    html =<<-HTML
      <div class="button rollover_button">
        <a class="button_#{name}_#{I18n.locale} button_#{name}" href="#">
          <button type="submit" id="#{button_options.delete(:id)}" #{button_options.collect{|k,v| "#{k}=\"#{v}\"" }.join(" ")}>
            <span>#{text}</span>
          </button>
        </a>
      </div>
    HTML
    html.html_safe
  end

  def rollover_image_link(name, text, url, options={})
    optional_attrs = options.inject("") {|s,(k,v)| s << %Q[ #{k}="#{v}"] }
    html =<<-HTML
      <span class="button rollover_button">
        <a class="button_#{name}_#{I18n.locale} button_#{name}" href="#{url}"#{optional_attrs}><span>#{text}</span></a>
      </span>
    HTML
    html.html_safe
  end

  def partner_rollover_button(name, text)
    html =<<-HTML
      <div class="button rollover_button">
        <a class="button_#{name}" href="#"><button type="submit" id="partner_submit"><span>#{text}</span></button></a>
      </div>
    HTML
    html.html_safe
  end


  def asset_data_base64(path)
    asset = Rails.application.assets.find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def branding_open_requests_count
    BrandingUpdateRequest.all.count { |x| x.open? }
  end

  def find_canvassing_shift
    @canvassing_shift ||= nil
    if session[:canvassing_shift_id]
      @canvassing_shift = CanvassingShift.find_by_id(session[:canvassing_shift_id])
    end
  end
end
