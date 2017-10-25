class PARegistrantValidator < ActiveModel::Validator
  
  def validate(reg)
    
    #reg.validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
    #reg.validates_presence_of :phone_type if reg.has_phone?


    if reg.at_least_step_1?
      reg.validates_format_of :email, :with => Authlogic::Regex.email, :allow_blank => true

      reg.validates_inclusion_of  :confirm_will_be_18, :in=>[true]
      reg.validates_inclusion_of  :confirm_us_citizen, :in => [true]
      reg.validate_date_of_birth
      
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      reg.validates_presence_of   :registration_address_1 
      reg.validates_presence_of   :registration_unit_type if !reg.registration_unit_number.blank? 
      reg.validates_presence_of   :registration_unit_number if !reg.registration_unit_type.blank? 
      reg.validates_presence_of   :registration_city 
      validates_zip_code  reg,    :registration_zip_code
      reg.validates_presence_of   :registration_county

      if reg.change_of_name?
        reg.validates_presence_of :previous_first_name
        reg.validates_presence_of :previous_last_name
      end
  
      if reg.has_mailing_address? 
        reg.validates_presence_of :mailing_address
        reg.validates_presence_of :mailing_city
        reg.validates_presence_of :mailing_state
        validates_zip_code reg,   :mailing_zip_code
      end
  
      if reg.change_of_address?
        reg.validates_presence_of :previous_address
        reg.validates_presence_of :previous_city
        reg.validates_presence_of :previous_state
        reg.validates_presence_of :previous_county if reg.previous_state.to_s.downcase == "pa"
        validates_zip_code reg,    :previous_zip_code
      end

      validate_phone_present_if_opt_in_sms(reg)
    end
    
    if reg.at_least_step_2?
      validate_race(reg)        
      validate_party(reg)
      
      reg.validates_presence_of(:penndot_number) unless reg.confirm_no_penndot_number?
      reg.validates_presence_of(:ssn4) unless (reg.confirm_no_dl_or_ssn? || !reg.confirm_no_penndot_number?)
      if reg.has_assistant?
        reg.validates_presence_of(:assistant_name)
        reg.validates_presence_of(:assistant_address)
        reg.validates_presence_of(:assistant_phone)
        reg.validates_acceptance_of(:confirm_assistant_declaration)
      end
    end
    
    if reg.at_least_step_3?
      reg.validates_inclusion_of :confirm_declaration, :in => [true]
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
    if reg.opt_in_sms? && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end
  
  def validate_party(reg)
    if reg.party.blank?
      reg.errors.add(:party, :blank)
    else
      reg.errors.add(:party, :inclusion) unless reg.english_state_parties.include?(reg.english_party_name)
      if (reg.english_party_name.to_s.downcase == "other")
        reg.validates_presence_of(:other_party)
      end
    end
  end
  
  def validate_race(reg)
    if reg.race.blank?
      reg.errors.add(:race, :blank)
    else
      reg.errors.add(:race, :inclusion) unless reg.english_races.include?(reg.english_race)
    end
  end
  
  
  
end
