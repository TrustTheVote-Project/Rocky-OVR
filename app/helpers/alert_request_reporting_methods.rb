module AlertRequestReportingMethods
  CSV_HEADER = %w(
    uid
    first
    middle
    last
    date_of_birth
    email
    phone
    address
    address_2
    city
    state_abbrev
    zip
    opt_in_email
    opt_in_sms
    partner_opt_in_email
    partner_opt_in_sms
    tracking_source
    tracking_id
    original_survey_question_1
    original_survey_question_2
    survey_answer_1
    survey_answer_2
    created_at
    updated_at
  )

  def to_csv_array
    CSV_HEADER.collect{|m| self.send(m) }
  end

end