class AlertRequest < ApplicationRecord
  include DateOfBirthMethods
  include SurveyQuestionMethods
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
  validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
  validate :validate_date_of_birth
  validate :validates_zip
  # validate :validate_phone_present_if_opt_in_sms

  def to_param
    uid
  end

  def self.find_by_param(uid)
    find_by(uid: uid)
  end

  def locale
    'en'
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
end
