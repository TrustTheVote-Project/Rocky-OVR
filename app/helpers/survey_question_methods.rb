module SurveyQuestionMethods
  def skip_survey_and_opt_ins?
    question_1.blank? && question_2.blank? && !any_ask_for_volunteers? && !any_email_opt_ins? && !any_phone_opt_ins?
  end

  def question_1
    partner.send("survey_question_1_#{self.locale}")
  end
  def question_2
    partner.send("survey_question_2_#{self.locale}")
  end

  def ask_for_primary_volunteers?
    partner.primary? ? partner.ask_for_volunteers? : RockyConf.sponsor.allow_ask_for_volunteers && partner.ask_for_volunteers?
  end
  
  def ask_for_partner_volunteers?
    !partner.primary? && partner.partner_ask_for_volunteers?
  end
  
  def any_ask_for_volunteers?
    ask_for_primary_volunteers? || ask_for_partner_volunteers?
  end
end