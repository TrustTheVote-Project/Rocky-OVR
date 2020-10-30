class PARegistrantValidator < ActiveModel::Validator
  
  VALIDATABLE_ATTRS = StateRegistrants::PARegistrant.attribute_names
    #.reject{|attr| NON_VALIDATABLE_ATTRS.include?(attr)}
  
  def validate(reg)
    @use_newui2020 = reg.ab_tests.detect { |t| t.name==AbTest::NEW_UI_2020 }&.assignment == AbTest::NEW
 
    # Validate all fields against db regex
    
    reg.validates_format_of VALIDATABLE_ATTRS, with: Registrant::DB_REGEX
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end

    reg.validates_presence_of :phone_type if reg.has_phone?

    if reg.at_least_step_1?
      
      reg.validates_format_of :email, :with => Authlogic::Regex::EMAIL, :allow_blank => true
     unless @use_newui2020
      reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
      reg.validates_acceptance_of  :confirm_us_citizen, :accept=>true
     
      reg.validate_date_of_birth
     end  
      reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name
      reg.validates_presence_of   :last_name
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      reg.validates_presence_of   :registration_address_1 
      reg.validates_presence_of   :registration_unit_type if !reg.registration_unit_number.blank? 
      reg.validates_length_of     :registration_unit_number, maximum: 15
      
      reg.validates_presence_of   :registration_city 
      validates_zip_code  reg,    :registration_zip_code
      reg.validates_presence_of   :registration_county

      if @use_newui2020
        validate_boolean(reg, :change_of_name )

      end

      if reg.change_of_name?
        reg.validates_presence_of :previous_first_name
        reg.validates_presence_of :previous_last_name
      end
  
      if @use_newui2020
        validate_boolean(reg, :has_mailing_address )
      end

      if reg.has_mailing_address? 
        reg.validates_presence_of :mailing_address
        reg.validates_presence_of :mailing_city
        reg.validates_presence_of :mailing_state
        validates_zip_code reg,   :mailing_zip_code
      end
  
      if @use_newui2020
        validate_boolean(reg, :change_of_address )
      end

      if reg.change_of_address?
        reg.validates_presence_of :previous_address
        reg.validates_presence_of :previous_city
        reg.validates_presence_of :previous_state
        reg.validates_presence_of :previous_county if reg.previous_state.to_s.downcase == "pa"
        validates_zip_code reg,    :previous_zip_code
      end

      validate_phone_present_if_opt_in_sms(reg)
      
      unless @use_newui2020
        #if not newUI
        validate_race(reg)        
        validate_party(reg) 
      end
     
    end
    
    if reg.at_least_step_2?
      
      validate_id(reg)
      if reg.has_assistant?
        reg.validates_presence_of(:assistant_name)
        reg.validates_presence_of(:assistant_address)
        reg.validates_presence_of(:assistant_phone)
        
        reg.validates_acceptance_of(:confirm_assistant_declaration, accept: true)
        if !reg.assistant_phone.blank?
          reg.errors.add(:assistant_phone, :invalid) unless reg.assistant_phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/          
        end
        
      end
      if reg.signature_method != VoterSignature::PRINT_METHOD && reg.confirm_no_penndot_number? || reg.penndot_retries > 1
        reg.validates_presence_of(:voter_signature_image)
      elsif reg.penndot_retries > 1
        reg.errors.add(:voter_signature_image, :too_many_retries) if reg.voter_signature_image.blank?
      end

      if @use_newui2020 
        reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
        reg.validates_acceptance_of  :confirm_us_citizen, :accept=>true
      
        reg.validate_date_of_birth

        validate_race(reg)        
        validate_party(reg) 

        validate_penndot(reg )
      end

      
    end
    
    if reg.at_least_step_3?
      if @use_newui2020
        validate_boolean(reg, :has_assistant )    
      end
      reg.validates_acceptance_of :confirm_declaration, :accept=>true
    end

    if reg.at_least_step_4?

    end
    

  end

  def validate_boolean(reg, attr_name)
    unless [true, false].include? reg.send(attr_name) 
      reg.validates_presence_of attr_name
    end
  end
  def validate_penndot(reg)
    unless [true, false].include? reg.send :confirm_no_penndot_number 
      reg.validates_presence_of :has_penndot
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
    if (reg.opt_in_sms? || reg.partner_opt_in_sms?) && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end
  
  def validate_id(reg)
    unless reg.confirm_no_penndot_number?
      reg.validates_presence_of(:penndot_number) 
      reg.errors.add(:penndot_number, :format) unless reg.penndot_number.to_s.gsub(/[^\d]/,'') =~ /\A\d{8}\z/ || reg.penndot_number.blank?
    end
    unless reg.confirm_no_dl_or_ssn?
      reg.validates_presence_of(:ssn4) if reg.confirm_no_penndot_number? 
      reg.errors.add(:ssn4, :format) unless (reg.ssn4.to_s.gsub(/[^\d]/,'') =~ /\A\d{4}\z/) || reg.ssn4.blank?
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
    if !reg.race.blank?
      reg.errors.add(:race, :inclusion) unless reg.english_races.include?(reg.english_race)
    end
  end
  
  
  
end
