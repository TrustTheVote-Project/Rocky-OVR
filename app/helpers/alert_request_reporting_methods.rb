module AlertRequestReportingMethods
  
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def csv_header
      csv_columns.collect {|m,l| l}
    end
    
    def csv_methods
      csv_columns.collect {|m,l| m}
    end
    
    def csv_columns
      [
        ["uid", "Pledge UID"],
        ["locale", "Language"],
        ["first", "First name"],
        ["middle", "Middle name"],
        ["last", "Last name"],
        ["date_of_birth", "Date of birth"],
        ["email", "Email address"],
        ["phone", "Phone"],
        ["address", "Home address"],
        ["address_2", "Home address line 2"],
        ["city", "Home city"],
        ["state_abbrev", "Home state"],
        ["zip", "Home zip code"],
        ["opt_in_email_yn", "Opt-in to RTV email?"],
        ["opt_in_sms_yn", "Opt-in to RTV sms?"],
        ["partner_opt_in_email_yn", "Opt-in to Partner email?"],
        ["partner_opt_in_sms_yn", "Opt-in to Partner SMS/robocall"],
        ["tracking_source", "Tracking Source"],
        ["tracking_id", "Tracking ID"],
        ["original_survey_question_1", "Survey question 1"],
        ["original_survey_question_2", "Survey question 2"],
        ["survey_answer_1", "Survey answer 1"],
        ["survey_answer_2", "Survey answer 2"],
        ["created_at", "Submitted At"],
      ]
    end
  end

  def opt_in_email_yn
    yes_no(opt_in_email)
  end
  def opt_in_sms_yn
    yes_no(opt_in_sms)
  end
  def partner_opt_in_email_yn
    yes_no(partner_opt_in_email)
  end
  def partner_opt_in_sms_yn
    yes_no(partner_opt_in_sms)
  end

  def to_csv_array
    self.class.csv_methods.collect{|m| self.send(m) }
  end

end