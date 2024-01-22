class RegistrantValidator < ActiveModel::Validator
  
  def validate(reg)
    
    #regexp = /\A(none|\d{4}|([-*A-Z0-9]{7,42}(\s+\d{4})?))\z/i
    
    
    reg.validates_format_of :phone, with: /\A\(*[1-9]\d{2}\)*[-\s]*[1-9]\d{2}[-\s]*[1-9]\d{3}\z/, allow_blank: true
    
    reg.validates_format_of :email_address, :with => Registrant::EMAIL_REGEX, :allow_blank => true
    validate_email(reg)
    reg.validates_presence_of :phone_type if reg.has_phone?

     if reg.at_least_step_1?
      reg.validates_presence_of     :partner_id #, :unless=>[:remote_partner_id_present?]

      if !reg.use_short_form?
        reg.validates_inclusion_of  :has_state_license, :in=>[true,false] unless reg.building_via_api_call?
        reg.validate_date_of_birth

        reg.validates_inclusion_of  :will_be_18_by_election, :in=>[true,false] unless reg.building_via_api_call?
        reg.validates_inclusion_of  :us_citizen, :in => [ false, true ] unless reg.building_via_api_call?
      end
      
    
      reg.validates_inclusion_of  :locale, :in => RockyConf.enabled_locales
      reg.validates_presence_of   :email_address unless reg.not_require_email_address?
      reg.validates_presence_of   :home_state_id
    end
    
    if (reg.at_least_step_1? && (!reg.use_short_form? || reg.home_state_id.blank?)) ||
       (reg.at_least_step_2? && reg.use_short_form? )
      validates_zip_code  reg,    :home_zip_code
      
    end
    
    if reg.at_least_step_2?
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name unless reg.building_via_api_call?
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      reg.validates_presence_of   :home_address unless reg.finish_with_state?
      reg.validates_presence_of   :home_city unless reg.finish_with_state?
      reg.validates_inclusion_of :us_citizen, :in => [true], message: :accepted unless reg.building_via_api_call?
    
      validate_phone_present_if_opt_in_sms(reg)
      if reg.mail_with_esig?
        reg.validates_presence_of(:voter_signature_image)
      end
    end
    
    if requires_presence_of_state_id_number(reg)
      reg.validates_presence_of :state_id_number unless reg.complete?
      validate_state_id_number(reg)
    end
    # if reg.at_least_step_3? || (reg.at_least_step_2? && reg.use_short_form?)
    #   validate_state_id_number(reg)
    # end
    
    
    if reg.at_least_step_2? && reg.use_short_form? 
      if reg.home_state_allows_ovr_ignoring_license? && reg.require_id?
        reg.validates_inclusion_of  :has_state_license, :in=>[true,false]
      end
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
      unless reg.in_ovr_flow?
        validate_race(reg)        
      end
    end
  
    if requires_validate_party(reg)
       validate_party(reg)
    end

  
  
    if reg.at_least_step_4? && !reg.using_state_online_registration?
      validate_race(reg)        
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

    if reg.at_least_step_5? && !reg.building_via_api_call? && !reg.use_short_form?
      reg.validates_inclusion_of  :attest_true, :in=>[true]
      #reg.validates_acceptance_of :attest_true, :accept=>true
    end

    if reg.telling_friends
      reg.validates_presence_of :tell_from
      reg.validates_presence_of :tell_email
      reg.validates_format_of :tell_email, :with => Registrant::EMAIL_REGEX
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
      reg.validates_inclusion_of  :send_confirmation_reminder_emails, :in => [ true, false ]
    end
  
    city_regex = reg.home_state_abbrev.to_s.downcase == "ca" ? Registrant::CA_CITY_STATE_REGEX : Registrant::CITY_STATE_REGEX
    [
      #[Registrant::ADDRESS_FIELDS, Registrant::CA_ADDRESS_REGEX, "Valid characters are: A-Z a-z 0-9 # dash space comma forward-slash period"],
      [Registrant::CITY_FIELDS, city_regex, :invalid]
    ].each do |list, regex, message|
      list.each do |field|
        reg.validates_format_of field, with: regex, message: message
      end
    end

  end
  
  def requires_presence_of_state_id_number(reg)
    if reg.at_least_step_2? && reg.use_short_form? 
      if !reg.in_ovr_flow?
        return true
      end
    end
    if reg.at_least_step_3?
      unless reg.complete? || reg.in_ovr_flow?
        return true
      end
    end
    if reg.at_least_step_4? && !reg.using_state_online_registration?
      unless reg.complete?
        return true
      end      
    end
  end
  
  def validate_state_id_number(reg)
    return true if reg.state_id_number.blank?
    regexp = /\A(none|\d{4}|([-*A-Z0-9\s]{7,42}(\s+\d{4})?))\z/i
    
    if (reg.state_id_number =~ regexp)==nil
      reg.errors.add(:state_id_number, :invalid)
    end
  end
  
  
  def requires_validate_party(reg)
    return false if reg.building_via_api_call?
    if reg.at_least_step_3? && !reg.in_ovr_flow?
      return true
    end
    if reg.at_least_step_4? && !reg.using_state_online_registration?
      return true
    end    
    return false
  end
  
  def validate_email(reg)
    unless reg.email_address.blank?
      if EmailAddress.is_blacklisted?(reg.email_address) && (!reg.building_via_api_call? || reg.api_version == "4")
        reg.errors.add(:email_address, :invalid)
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
  
  def validate_phone_present_if_opt_in_sms(reg)
    return true if reg.building_via_api_call?
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
        reg.errors.add(:race, :inclusion) unless reg.english_races.include?(reg.english_race)
      end
    end
  end
  
  
  
end
