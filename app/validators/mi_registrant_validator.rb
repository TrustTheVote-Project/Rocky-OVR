class MIRegistrantValidator < ActiveModel::Validator
  
  def validate(reg)
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end
    
    if reg.at_least_step_1?
      reg.validates_format_of :email, :with => Authlogic::Regex::EMAIL, :allow_blank => true
      reg.validates_format_of :email, with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
      #reg.validates_length_of :email, maximum: 80
      
      #reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
    end
    if reg.at_least_step_1?
      reg.validates_acceptance_of  :confirm_us_citizen, :accept=>true
      reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
      reg.validates_acceptance_of  :is_30_day_resident, :accept=>true
      if !reg.registration_cancellation_authorized
        reg.errors.add(:registration_cancellation_authorized, I18n.t('states.custom.mi.custom_errors.registration_cancellation_authorized', url: reg.skip_state_flow_registrant_path).html_safe)
      end
      if !reg.digital_signature_authorized
        reg.errors.add(:digital_signature_authorized, I18n.t('states.custom.mi.custom_errors.digital_signature_authorized', url: reg.skip_state_flow_registrant_path).html_safe)
      end
      
      if reg.updated_dln_recently != false
        reg.errors.add(:updated_dln_recently, I18n.t('states.custom.mi.custom_errors.updated_dln_recently', url: reg.skip_state_flow_registrant_path).html_safe)
      end
      if reg.requested_duplicate_dln_today != false
        reg.errors.add(:requested_duplicate_dln_today, I18n.t('states.custom.mi.custom_errors.requested_duplicate_dln_today', url: reg.skip_state_flow_registrant_path).html_safe)
      end
      
    end

    if reg.at_least_step_2?
      reg.validates_presence_of   :full_name
      reg.validates_length_of :full_name, maximum: 255
      reg.validates_format_of :full_name, with: /\A(?=.{1,255}$)[a-zA-Z]+(?:[-=_.`;'\s][a-zA-Z]+)*\z/, allow_blank: true
      reg.validate_date_of_birth
      validate_age(reg)
      if reg.dln.blank?
        reg.errors.add(:dln, I18n.t('states.custom.mi.custom_errors.dln', url: reg.skip_state_flow_registrant_path))
      end
      reg.validates_format_of :dln, with: /\A[a-zA-Z]\d{12}\z/, allow_blank: true
      
      if reg.ssn4.blank?
        reg.errors.add(:ssn4, I18n.t('states.custom.mi.custom_errors.ssn4', url: reg.skip_state_flow_registrant_path))
      end
      reg.validates_format_of :ssn4, with: /\A\d{4}\z/, allow_blank: true
      reg.validates_presence_of :eye_color_code
    end
    
    if reg.at_least_step_3?

      reg.validates_presence_of   :registration_address_number
      reg.validates_format_of :registration_address_number, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      reg.validates_presence_of   :registration_address_street_name
      reg.validates_format_of :registration_address_street_name, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      reg.validates_length_of :registration_address_street_name, maximum: 255
      reg.validates_format_of :registration_address_street_type, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      validates_street_type reg
      validate_address_line(reg, [:registration_address_street_name, :registration_address_number, :registration_address_street_type, :registration_address_post_directional])
      
      reg.validates_length_of :registration_unit_number, maximum: 50
      
      
      reg.validates_presence_of   :registration_city 
      reg.validates_length_of :registration_city, maximum: 100
      reg.validates_format_of :registration_city, with: /\A(?=.{1,255}$)[a-zA-Z]+(?:[-=_.`;'\s][a-zA-Z]+)*\z/
      validates_zip_code  reg,    :registration_zip_code
      
      validate_phone_present_if_opt_in_sms(reg)
      
      
      reg.validates_acceptance_of :confirm_affirm_privacy_notice, :accept=>true

      
    end
    
    
    if reg.has_mailing_address? && reg.at_least_step_3?
      reg.validates_presence_of :mailing_address_type
      reg.validates_presence_of :mailing_address_1
      
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::STANDARD_TYPE
        reg.validates_presence_of :mailing_address_2
        #reg.validates_presence_of :mailing_address_3
        validate_address_line(reg, [:mailing_address_2, :mailing_address_1, :mailing_address_3])
        reg.validates_length_of :mailing_address_unit_number, maximum: 50
        reg.validates_presence_of :mailing_city
        reg.validates_length_of :mailing_city, maximum: 50
        reg.validates_presence_of :mailing_state
        reg.validates_length_of :mailing_state, maximum: 2
        
        validates_zip_code reg,    :mailing_zip_code
        
      end
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::PO_BOX_TYPE
        reg.validates_format_of :mailing_address_1, with: /\A[\d\s-]+\z/, message: I18n.t('states.custom.mi.custom_errors.po_box.mailing_address_1'), allow_blank: true
        reg.validates_length_of :mailing_address_1, maximum: 50, message: I18n.t('states.custom.mi.custom_errors.po_box.mailing_address_1_length')
        reg.validates_presence_of :mailing_city
        reg.validates_length_of :mailing_city, maximum: 50
        reg.validates_presence_of :mailing_state
        reg.validates_length_of :mailing_state, maximum: 2
        
      end
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::MILITARY_TYPE
        reg.validates_presence_of :mailing_address_2
        reg.validates_presence_of :mailing_address_3
        validates_zip_code reg,    :mailing_zip_code
        validate_address_line(reg, [:mailing_address_2, :mailing_address_1, :mailing_address_3])
        reg.validates_presence_of :mailing_city
        reg.validates_length_of :mailing_city, maximum: 50
        
        reg.validates_presence_of :mailing_state
      end
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::INTERNATIONAL_TYPE
        #validate_address_line(reg, [:mailing_address_1, :mailing_address_2, :mailing_address_3])        
        reg.validates_length_of :mailing_address_1, maximum: 50, message: :address_length
        reg.validates_length_of :mailing_address_2, maximum: 50, message: :address_length
        reg.validates_length_of :mailing_address_3, maximum: 50, message: :address_length
        
        reg.validates_presence_of :mailing_country
        reg.validates_format_of :mailing_country, with: /\A[a-zA-Z\s\/',\.-]*\z/
        reg.validates_length_of :mailing_country, maximum: 50
        reg.validates_presence_of :mailing_zip_code
        reg.validates_length_of :mailing_zip_code, maximum: 50
        
        reg.validates_format_of :mailing_zip_code, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      end
    end
    

  end
  
  def validate_age(reg)
    return if reg.date_of_birth.blank?
    earliest_date = Date.today - 17.years - 6.months
    if reg.date_of_birth > earliest_date
      reg.errors.add(:date_of_birth, :too_young)
    end
  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /\A\d{5}\z/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid, :default => nil, :value => reg.send(attr_name))
    end
  end
  
  def validate_address_line(reg, methods)
    concatenated = methods.collect{|m| reg.send(m)}.join(" ")
    if concatenated.length > 50
      reg.errors.add(methods.first, :address_length)
    end
  end
  
  
  def validates_street_type(reg)
    if reg.registration_address_street_type.present? && !reg.street_types.values.collect(&:capitalize).include?(reg.registration_address_street_type.capitalize)
      reg.errors.add(:registration_address_street_type, :invalid)
    end    
  end
  
  def validate_phone_present_if_opt_in_sms(reg)
    if reg.opt_in_sms? && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end
  
  
  
end
