class MIRegistrantValidator < ActiveModel::Validator
  
  def validate(reg)
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end
    
    if reg.at_least_step_1?
      reg.validates_format_of :email, :with => Authlogic::Regex::EMAIL, :allow_blank => true
      reg.validates_format_of :email, with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
      #reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
    end
    if reg.at_least_step_1?
      reg.validates_acceptance_of  :confirm_us_citizen, :accept=>true
      reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
      reg.validates_acceptance_of  :is_30_day_resident, :accept=>true
      reg.validates_acceptance_of  :registration_cancellation_authorized, :accept=>true
      reg.validates_acceptance_of  :digital_signature_authorized, :accept=>true
    end

    if reg.at_least_step_2?
      reg.validates_presence_of   :full_name
      reg.validates_length_of :full_name, maximum: 255
      reg.validates_format_of :full_name, with: /\A(?=.{1,255}$)[a-zA-Z]+(?:[-=_.`;'\s][a-zA-Z]+)*\z/
      reg.validate_date_of_birth
      reg.validates_presence_of :dln
      reg.validates_presence_of :ssn4
      reg.validates_format_of :ssn4, with: /\A\d{4}\z/
      reg.validates_presence_of :eye_color_code
    end
    
    if reg.at_least_step_3?

      reg.validates_presence_of   :registration_address_number
      reg.validates_presence_of   :registration_address_street_name
      reg.validates_format_of :registration_address_street_name, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      reg.validates_length_of :registration_address_street_name, maximum: 255
      reg.validates_presence_of   :registration_address_street_type
      validates_street_type reg
      
      
      reg.validates_presence_of   :registration_city 
      reg.validates_length_of :registration_city, maximum: 255
      reg.validates_format_of :registration_city, with: /\A(?=.{1,255}$)[a-zA-Z]+(?:[-=_.`;'\s][a-zA-Z]+)*\z/
      validates_zip_code  reg,    :registration_zip_code
      
      validate_phone_present_if_opt_in_sms(reg)
      
      
      reg.validates_acceptance_of :confirm_affirm_privacy_notice, :accept=>true

      
    end
    
    
    if reg.has_mailing_address? && reg.at_least_step_3?
      reg.validates_presence_of :mailing_address_type
      reg.validates_presence_of :mailing_address_1
      reg.validates_presence_of :mailing_city
      reg.validates_presence_of :mailing_state
      
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::STANDARD_TYPE
        reg.validates_presence_of :mailing_address_2
        reg.validates_presence_of :mailing_address_3
        validates_zip_code reg,    :mailing_zip_code
      end
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::MILITARY_TYPE
        reg.validates_presence_of :mailing_address_2
        reg.validates_presence_of :mailing_address_3
        validates_zip_code reg,    :mailing_zip_code
      end
      if reg.mailing_address_type == StateRegistrants::MIRegistrant::MailingAddress::INTERNATIONAL_TYPE
        reg.validates_presence_of :mailing_country
        reg.validates_format_of :mailing_country, with: /\A[a-zA-Z\s\/',\.-]*\z/
        reg.validates_presence_of :mailing_zip_code
        reg.validates_format_of :mailing_zip_code, with: /\A[a-zA-Z0-9\s_#\/',\.-]*\z/
      end
    end
    

  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /\A\d{5}(-\d{4})?\z/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid, :default => nil, :value => reg.send(attr_name))
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
