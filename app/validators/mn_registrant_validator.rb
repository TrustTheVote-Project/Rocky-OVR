class MNRegistrantValidator < ActiveModel::Validator
  VALIDATABLE_ATTRS = StateRegistrants::MNRegistrant.attribute_names
  
  def validate(reg)
    
    reg.validates_format_of VALIDATABLE_ATTRS, with: Registrant::DB_REGEX
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end
    #reg.validates_presence_of :phone_type if reg.has_phone?

    reg.validates_presence_of :phone_type if reg.has_phone?


    if reg.at_least_step_1?
      reg.validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
      reg.validates_presence_of   :email unless reg.not_require_email_address?

      reg.validates_inclusion_of  :locale, :in => RockyConf.enabled_locales

      validates_zip_code  reg,    :home_zip_code
    end

    if reg.at_least_step_2?
      reg.validates_inclusion_of  :confirm_eligibility, in: [true], message: I18n.t('states.custom.mn.custom_errors.confirm_eligibility')
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true

      reg.validate_date_of_birth
      
      unless reg.confirm_no_dln?
        reg.validates_presence_of :dln
      end

      if reg.confirm_no_dln? && !reg.confirm_no_dl_or_ssn?
        reg.errors.add(:ssn4, :format) unless reg.ssn_digits.length == 4        
      end

      validate_phone_present_if_opt_in_sms(reg)
      
    end

    if reg.at_least_step_3?
      reg.validates_presence_of   :home_address
      reg.validates_presence_of   :home_city
      
    end

    if reg.at_least_step_4?
      reg.validates_acceptance_of :confirm_declaration, :accept=>true
      if reg.signature_method != VoterSignature::PRINT_METHOD
        reg.validates_presence_of(:voter_signature_image)
      end
      
    end

    if reg.has_mailing_address? 
      reg.validates_presence_of :mailing_address
      reg.validates_presence_of :mailing_city
      reg.validates_presence_of :mailing_state_id
      validates_zip_code reg,    :mailing_zip_code
    end

    if reg.change_of_address?
      reg.validates_presence_of :prev_address
      reg.validates_presence_of :prev_city
      reg.validates_presence_of :prev_state_id
      validates_zip_code reg,    :prev_zip_code
    end
    

  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /\A\d{5}(-\d{4})?\z/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid, :default => nil, :value => reg.send(attr_name))
    end
  end
  
  def validate_phone_present_if_opt_in_sms(reg)
    if reg.opt_in_sms? && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end
  
  
  
end
