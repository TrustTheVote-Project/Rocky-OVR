class AlertRequest < ApplicationRecord
  include DateOfBirthMethods
  include SurveyQuestionMethods
  include UidGenerator
  include RegistrantAbrMethods
  include AlertRequestReportingMethods
  include TrackableMethods
  
  
  # TODO create model fields for volunteering booleans before removing these overrides:
  def ask_for_primary_volunteers?
    false
  end
  def ask_for_partner_volunteers?
    false
  end

  belongs_to :partner, optional: true
  belongs_to :state, class_name: 'GeoState', optional: true

  validates_presence_of :first
  validates_presence_of :last
  validates_presence_of :date_of_birth
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :email
  validates_format_of   :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
  validates_presence_of :phone_type, if: -> { !phone.blank? }
  
  before_validation :clean_phone_number

  validates_format_of :phone, with: /\A(?!([0-9])\1{9})[1-9]\d{2}[-\s]*\d{3}[-\s]*\d{4}\z/, allow_blank: true

  def clean_phone_number
    self.phone = phone.gsub(/[^\d]/, '') if phone.present?
  end
  
  validate :validate_date_of_birth

  validate :validate_date_of_birth_min_age

  def validate_date_of_birth_min_age
    if date_of_birth.present? && date_of_birth > 13.years.ago.to_date
      errors.add(:date_of_birth, "Must be at least 13 years old")
    end
  end

  validate :validates_zip
  validate :validate_phone_present_if_opt_in_partner_sms

  ADDRESS_FIELDS = ["address", 
    "address_2"]

  CITY_FIELDS = ["city"]

  NAME_FIELDS = ["first", 
   "last", 
   "middle"]

  def self.validate_fields(list, regex, message)
    list.each do |field|
      validates field, format: { with: regex , 
        message: message }
    end    
  end
  
  validate_fields(NAME_FIELDS, Registrant::OVR_REGEX, :invalid)
  validate_fields(ADDRESS_FIELDS, Registrant::CA_ADDRESS_REGEX, "Valid characters are: A-Z a-z 0-9 # dash space comma forward-slash period")

  def validate_phone_present_if_opt_in_partner_sms
    if (self.partner_opt_in_sms?) && self.phone.blank?
      self.errors.add(:phone, :required_if_opt_in)
    end
  end
  

  def to_param
    uid
  end

  def self.find_by_param(uid)
    find_by(uid: uid)
  end

  def locale
    'en'
  end

  def email_address
    email
  end

  def collect_email_address?
    true
  end
  def use_short_form?
    true
  end
  def use_state_flow?
    false
  end

  
  def question_1
    partner&.send("survey_question_1_#{self.locale}")
  end

  def question_2
    partner&.send("survey_question_2_#{self.locale}")
  end

  def require_email_address?
    true
  end

  def state_abbrev
    state&.abbreviation
  end

  def validates_zip
    validates_zip_code(self, :zip)
  end
  
  def validates_zip_code(reg, attr_name)
    reg.validates_presence_of(attr_name)
    reg.validates_format_of(attr_name, {:with => /\A\d{5}(-\d{4})?\z/, :allow_blank => true});

    if reg.errors[attr_name].empty? && !GeoState.valid_zip_code?(reg.send(attr_name))
      reg.errors.add(attr_name, :invalid, :default => nil, :value => reg.send(attr_name))
    end
  end

  def no_emojis_in_survey_answers
    if survey_answer_1.present? && survey_answer_1.match(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{2300}-\u{23FF}\u{2B50}\u{2B55}]/)
      puts "Emoji found in survey_answer_1 before removal"
      self.errors.add(:survey_answer_1, :invalid_emoji)
      self.survey_answer_1 = remove_emojis(survey_answer_1)
    end

    if survey_answer_2.present? && survey_answer_2.match(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{2300}-\u{23FF}\u{2B50}\u{2B55}]/)
      puts "Emoji found in survey_answer_2 before removal"
      self.errors.add(:survey_answer_2, :invalid_emoji)
      self.survey_answer_2 = remove_emojis(survey_answer_2)
    end
  end


  private

  def remove_emojis(text)
    text.gsub(/\p{Emoji}/, '')
  end

end
