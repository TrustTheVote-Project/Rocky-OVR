class VARegistrantValidator < ActiveModel::Validator
  VALIDATABLE_ATTRS = StateRegistrants::VARegistrant.attribute_names
  
  def validate(reg)
    
    reg.validates_format_of VALIDATABLE_ATTRS, with: Registrant::DB_REGEX
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end
    #reg.validates_presence_of :phone_type if reg.has_phone?

    reg.validates_presence_of :phone_type if reg.has_phone?


    if reg.at_least_step_1?
      reg.validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true

      #reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
      reg.validates_acceptance_of  :confirm_us_citizen, :accept=>true
      reg.validates_acceptance_of  :confirm_voter_record_update, :accept=>true
      
      reg.validate_date_of_birth
      
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name
      unless reg.confirm_no_middle_name?
        reg.validates_presence_of   :middle_name
      end
      if reg.middle_name.blank?
        reg.validates_acceptance_of :confirm_no_middle_name, :accept=>true
      end
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      reg.validates_presence_of   :registration_address_1 
      
      reg.validates_presence_of   :registration_city 
      validates_zip_code  reg,    :registration_zip_code
      reg.validates_presence_of   :registration_locality

      if reg.change_of_name?
        reg.validates_presence_of :previous_first_name
        reg.validates_presence_of :previous_last_name
      end
      
      
      if reg.registered_in_other_state?
        reg.validates_presence_of :other_registration_state_abbrev
      end
  
      if reg.requires_mailing_address? 
        reg.validates_presence_of :mailing_address_1
        reg.validates_presence_of :mailing_city
        reg.validates_presence_of :mailing_state
        validates_zip_code reg,   :mailing_zip_code
        if reg.mailing_state == "VA"
          reg.validates_presence_of :mailing_address_locality
        end          
      end
  
      
      validate_phone_present_if_opt_in_sms(reg)
    end

    if reg.at_least_step_2?
      reg.validates_inclusion_of :convicted_of_felony, :in => [true, false]
      if reg.convicted_of_felony?
        reg.validates_inclusion_of :right_to_vote_restored, :in => [true, false]
      end
    end
    
    if reg.at_least_step_2?
      reg.validates_acceptance_of :confirm_affirm_privacy_notice, :accept=>true

      
      unless reg.confirm_no_ssn?
        reg.validates_presence_of :ssn
        reg.errors.add(:ssn, :format) unless reg.ssn_digits.length == 9
        unless reg.confirm_no_dln?
          reg.errors.add(:dln, :blank) if reg.dln_digits.blank?
          reg.errors.add(:dln, :format) unless reg.dln_digits.length == 9
        end
      end
    end
    
    if reg.at_least_step_3?
      reg.validates_acceptance_of :confirm_voter_fraud_warning, :accept=>true
      reg.validates_acceptance_of :confirm_register_to_vote, :accept=>true
    end
    
    if reg.has_mailing_address? 
      reg.validates_presence_of :mailing_address_1
      reg.validates_presence_of :mailing_city
      reg.validates_presence_of :mailing_state
      validates_zip_code reg,    :mailing_zip_code
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
