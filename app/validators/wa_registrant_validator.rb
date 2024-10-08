class WARegistrantValidator < ActiveModel::Validator
  VALIDATABLE_ATTRS = StateRegistrants::WARegistrant.attribute_names
  
  def validate(reg)
    
    reg.validates_format_of VALIDATABLE_ATTRS, with: Registrant::DB_REGEX
    
    if !reg.phone.blank?
      reg.errors.add(:phone, :invalid) unless  reg.phone.to_s.gsub(/[^\d]/,'')=~ /\A\d{10}\z/
    end
    reg.validates_presence_of :phone_type if reg.has_phone?


    if reg.at_least_step_1? 

      if reg.confirm_no_dln?
        reg.skip_state_flow!
        return
      end

      #CTW 2022 reg.validates_format_of :email, :with => Authlogic::Regex::EMAIL, :allow_blank => true
      reg.validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true

      reg.validates_acceptance_of  :confirm_will_be_18, :accept=>true
      
      reg.validates_acceptance_of  :is_citizen, :accept=>true,:allow_nil=>false
      #reg.validates_acceptance_of  :confirm_voter_record_update, :accept=>true,:allow_nil=>false
      
      reg.validate_date_of_birth
      validate_age(reg)
      
      reg.validates_presence_of   :name_title
      #reg.validates_inclusion_of  :name_title, :in => Registrant::TITLES, :allow_blank => true
      reg.validates_presence_of   :first_name

      
      reg.validates_presence_of   :last_name
      #reg.validates_presence_of   :name_title
      reg.validates_inclusion_of  :name_suffix, :in => Registrant::SUFFIXES, :allow_blank => true
      

      reg.validates_presence_of   :residence_address 
      
      reg.validates_presence_of   :residence_city 
      validates_zip_code  reg,    :residence_zip

      #reg.validates_presence_of   :residence_locality  #CTW to do?

      if reg.has_previous_name?
        reg.validates_presence_of :prev_first_name
        reg.validates_presence_of :prev_last_name
        reg.validates_presence_of :prev_name_title
      end

      if reg.has_previous_address?
        reg.validates_presence_of :prev_residence_address
        reg.validates_presence_of :prev_residence_city 
        reg.validates_presence_of :prev_residence_state 
        reg.validates_presence_of :prev_residence_zip 

        validates_zip_code(reg, :prev_residence_zip)
        validates_wa_zip_code(reg, :prev_residence_zip)
      end



  
      #if reg.requires_mailing_address?  #CTW converted to has mailing...
      if reg.has_mailing_address? 
        reg.validates_presence_of :mailing_address
        reg.validates_presence_of :mailing_city
        reg.validates_presence_of :mailing_state
        validates_zip_code reg,   :mailing_zip       
      end
      
      validate_phone_present_if_opt_in_sms(reg)

      unless reg.confirm_no_dln
        validate_dln_ssn(reg)
  
        reg.validates_presence_of :issue_date
        date=nil
        date = Date.civil(reg.issue_date_year.to_i, reg.issue_date_month.to_i, reg.issue_date_day.to_i) rescue nil
        if (date.nil?)
          reg.errors.add(:issue_date, :format)
        end
  
        validate_issue_date(reg)
      end



    end
  

    if reg.at_least_step_2?
      #reg.validates_acceptance_of  :has_dln, :accept=>true,:allow_nil=>false
      #reg.validates_presence_of :driver_license

      if !reg.signature_method.blank? &&  reg.signature_method == VoterSignature::PRINT_METHOD
        reg.skip_state_flow!
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

  def validates_wa_zip_code(reg,attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /\A\d{5}(-\d{4})?\z/, :allow_blank => true});

    if reg.errors[attr_name].empty? && (GeoState.for_zip_code(reg.send(attr_name)) != GeoState["WA"] )
      reg.errors.add(attr_name, :wrongstate, :default => nil, :value => reg.send(attr_name))
    end



  end
  
  def validate_phone_present_if_opt_in_sms(reg)
    if reg.opt_in_sms? && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end

  def validate_boolean(reg, attr_name)
    unless [true, false].include? reg.send(attr_name) 
      reg.validates_presence_of attr_name
    end
  end

    
  def validate_dln_ssn(reg)
      reg.validates_presence_of(:driver_license) 
      reg.errors.add(:driver_license, :format) unless reg.driver_license.blank? || reg.driver_license.length==12
      #reg.penndot_number.to_s.gsub(/[^\d]/,'') =~ /\A\d{8}\z/ || reg.penndot_number.blank?
    #end
    #unless reg.confirm_no_dl_or_ssn?
      #reg.validates_presence_of(:ssn4) if reg.confirm_no_penndot_number? 
      reg.errors.add(:ssn4, :format) unless (reg.ssn4.to_s.gsub(/[^\d]/,'') =~ /\A\d{4}\z/) || reg.ssn4.blank?
    #end
  end

  def validate_age(reg)
    return if reg.date_of_birth.blank?
    earliest_date = Date.today - 16.years 
    if reg.date_of_birth > earliest_date
      reg.registrant.ineligible_age=true
      #Do nothing now
      #reg.errors.add(:date_of_birth, :too_young)
    end
  end

  def validate_issue_date(reg)
    return if reg.issue_date.blank?
    latest_date = Date.today 
    if reg.issue_date > latest_date
      reg.errors.add(:issue_date, :future)
    end
    if reg.issue_date < Date.today - 50.years
      reg.errors.add(:issue_date, :too_old)
    end
  end
  
  
  
end
