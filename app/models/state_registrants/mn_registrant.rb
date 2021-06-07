class StateRegistrants::MNRegistrant < StateRegistrants::Base
  belongs_to :prev_state,    :class_name => "GeoState"
    
  delegate :allow_desktop_signature?, to: :registrant
  def steps
    %w(step_1 step_2 step_3 step_4 step_5 complete)
  end
  
  def num_steps
    4
  end

  def signature_step
    "step_5"
  end

  def home_state
    home_zip_code.blank? ? GeoState[self.default_state_abbrev] : GeoState.for_zip_code(home_zip_code.strip)
  end

  def complete?
    status == step_list.last && valid? && confirm_eligibility? && confirm_declaration?
  end

  def mappings
    {
      "email" => "email_address",
      #"confirm_us_citizen"  => "us_citizen",
      #"confirm_will_be_18"  => "will_be_18_by_election",
      "date_of_birth" => "date_of_birth",
      "name_title"  => "name_title",
      "first_name"  => "first_name",
      "middle_name" => "middle_name",
      "last_name" => "last_name",
      "name_suffix" => "name_suffix",
      # "change_of_name"  => "change_of_name",
      # "previous_first_name" => "prev_first_name",
      # "previous_last_name"  => "prev_last_name",
      # "previous_middle_name" => "prev_middle_name",

      "home_address" => "home_address",
      "home_unit" => "home_unit",
      "home_city" => "home_city",
      "home_zip_code" => "home_zip_code",
      
      "has_mailing_address" => "has_mailing_address",
      "mailing_address" => "mailing_address",
      "mailing_city"  => "mailing_city",
      "mailing_zip_code"  => "mailing_zip_code",

      "change_of_address" => "change_of_address",
      "prev_address" => "prev_address",
      "prev_city" => "prev_city",
      "prev_unit" => "prev_unit",
      "prev_state_id" => "prev_state_id",
      "prev_zip_code" => "prev_zip_code",


      "opt_in_email"  => "opt_in_email",
      "opt_in_sms"  => "opt_in_sms",
      "volunteer" => "volunteer",
      "phone" => "phone",
      "phone_type" => "phone_type",
      "partner_opt_in_email"=>"partner_opt_in_email",
      "partner_opt_in_sms"=>"partner_opt_in_sms",
      "partner_volunteer"=>"partner_volunteer",
      

      "locale"  => "locale",
      "original_survey_question_1" => "original_survey_question_1",
      "original_survey_question_2" => "original_survey_question_2",
      "survey_answer_1" => "survey_answer_1",
      "survey_answer_2" => "survey_answer_2"
    }
  end


  def update_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = self.send(k)
      r.send("#{v}=", val)
    end
    
    r.has_state_license = !self.confirm_no_dln?
    r.has_ssn = self.confirm_no_dln? && !self.confirm_no_dl_or_ssn?
    
    r.us_citizen = self.confirm_eligibility
    r.will_be_18_by_election = self.confirm_eligibility
    
    r.state_id_number = self.dln.blank? ? self.ssn4 : self.dln

    if !self.mailing_state.blank? #always an abbrev
      r.mailing_state = GeoState[self.mailing_state]
    else
      r.mailing_state = nil
    end
    r.save(validate: false)
  end

  def set_from_original_registrant
    r = self.registrant
    mappings.each do |k,v|
      val = r.send(v)
      self.send("#{k}=", val)
    end
    
    if r.mailing_state
      self.mailing_state = r.mailing_state.abbreviation
    end

    self.save(validate: false)
  end

  
  def has_state_license?
    !self.confirm_no_dln?
  end
  
  def has_ssn?
    !self.confirm_no_ssn?
  end


end
