class RegistrantValidator < ActiveModel::Validator
  def validate(reg)
    
     if reg.at_least_step_1?
      reg.validates_presence_of   :partner_id #, :unless=>[:remote_partner_id_present?]

      if !reg.use_short_form?
        reg.validates_inclusion_of  :has_state_license, :in=>[true,false] unless reg.building_via_api_call?
        reg.validate_date_of_birth
      end
      
      reg.validates_inclusion_of  :will_be_18_by_election, :in=>[true,false] unless reg.building_via_api_call?
    
      reg.validates_inclusion_of  :locale, :in => RockyConf.enabled_locales
      reg.validates_presence_of   :email_address unless reg.not_require_email_address?
      reg.validates_format_of     :email_address, :with => Authlogic::Regex.email, :allow_blank => true
      validates_zip_code  reg,     :home_zip_code
      reg.validates_presence_of   :home_state_id
      reg.validates_inclusion_of  :us_citizen, :in => [ false, true ] unless reg.building_via_api_call?
    end
    
    if reg.at_least_step_2?
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name unless reg.building_via_api_call?
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      reg.validates_presence_of   :home_address unless reg.finish_with_state?
      reg.validates_presence_of   :home_city unless reg.finish_with_state?
    
      reg.validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
      reg.validates_presence_of :phone_type if reg.has_phone?
      validate_phone_present_if_opt_in_sms(reg)
    end
    
    if reg.at_least_step_2? && reg.use_short_form?
      reg.validates_presence_of :state_id_number unless reg.complete?
      reg.validates_format_of :state_id_number, :with => /^(none|\d{4}|[-*A-Z0-9\s]{7,42})$/i, :allow_blank => true
      reg.validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
      reg.validates_presence_of :phone_type if reg.has_phone?
      
      reg.validates_inclusion_of  :has_state_license, :in=>[true,false]
      reg.validate_date_of_birth

      #validate_phone_present_if_opt_in_sms(reg)
    end
    
    
    
    if reg.needs_mailing_address? 
      reg.validates_presence_of :mailing_address
      reg.validates_presence_of :mailing_city
      reg.validates_presence_of :mailing_state_id
      validates_zip_code reg,    :mailing_zip_code
    end
    

    if reg.at_least_step_3?
      unless reg.complete? || reg.in_ovr_flow?
        reg.validates_presence_of :state_id_number
      end
      reg.validates_format_of :state_id_number, :with => /^(none|\d{4}|[-*A-Z0-9\s]{7,42})$/i, :allow_blank => true
      unless reg.in_ovr_flow?
        validate_race(reg)
        
      end
      unless reg.in_ovr_flow? || reg.building_via_api_call?
        validate_party(reg)
      end
    end
  
    if reg.at_least_step_3? || (reg.at_least_step_2? && reg.use_short_form?)
      validate_state_id_number(reg)
    end
  

    if reg.needs_prev_name?
      reg.validates_presence_of :prev_name_title
      reg.validates_presence_of :prev_first_name
      reg.validates_presence_of :prev_last_name
    end
  
    if reg.needs_prev_address?
      reg.validates_presence_of :prev_address
      reg.validates_presence_of :prev_city
      reg.validates_presence_of :prev_state_id
      validates_zip_code reg,    :prev_zip_code
    end

    if reg.at_least_step_5?
      reg.validates_acceptance_of :attest_true
    end

    if reg.telling_friends
      reg.validates_presence_of :tell_from
      reg.validates_presence_of :tell_email
      reg.validates_format_of :tell_email, :with => Authlogic::Regex.email
      reg.validates_presence_of :tell_recipients
      reg.validates_presence_of :tell_subject
      reg.validates_presence_of :tell_message
    end

    if reg.building_via_api_call?
      reg.validates_inclusion_of :opt_in_email,                      :in => [ true, false ]
      reg.validates_inclusion_of :opt_in_sms,                        :in => [ true, false ]
      reg.validates_inclusion_of :us_citizen,                        :in => [ true ], :message=>"Required value is '1' or 'true'"
    end
    
    if reg.building_via_api_call? && reg.finish_with_state?
      validates_inclusion_of  :send_confirmation_reminder_emails, :in => [ true, false ]
    end
  
  
  
    
  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /^\d{5}(-\d{4})?$/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid_zip, :default => nil, :value => reg.send(attr_name))
    end
  end
  
  def validate_phone_present_if_opt_in_sms(reg)
    return true
    if (reg.opt_in_sms? || reg.partner_opt_in_sms?) && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end
  
  def validate_party(reg)
    if reg.requires_party?
      if reg.party.blank?
        reg.errors.add(:party, :blank)
      else
        reg.errors.add(:party, :inclusion) unless reg.english_state_parties.include?(reg.english_party_name)
      end
    end
  end
  
  def validate_race(reg)
    if reg.requires_race?
      if reg.race.blank?
        reg.errors.add(:race, :blank)
      else
        reg.errors.add(:race, :inclusion) unless english_races.include?(reg.english_race)
      end
    end
  end
  
  def validate_state_id_number(reg)
    return true if reg.state_id_number.blank?
    regexp = /^(none|\d{4}|([-*A-Z0-9]{7,42}(\s+\d{4})?))$/i
    if (reg.state_id_number =~ regexp)==nil
      reg.errors.add(:state_id_number, :invalid)
    end
  end
  
  
end