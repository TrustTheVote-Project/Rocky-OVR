class AlertRequest < ApplicationRecord
  include DateOfBirthMethods
  belongs_to :partner, optional: true
  belongs_to :state, class_name: 'GeoState', optional: true

  validates_presence_of :first
  validates_presence_of :last
  validates_presence_of :birthdate
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

  def question_1
    partner&.send("survey_question_1_#{self.locale}")
  end

  def question_2
    partner&.send("survey_question_2_#{self.locale}")
  end  

  def date_of_birth
    birthdate
  end

  def date_of_birth=(string_value)
    dob = nil
    if string_value.is_a?(String)
      if matches = string_value.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{4})\z/)
        m,d,y = matches.captures
        dob = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      elsif matches = string_value.match(/\A(\d{4})\D+(\d{1,2})\D+(\d{1,2})\z/)
        y,m,d = matches.captures
        dob = Date.civil(y.to_i, m.to_i, d.to_i) rescue string_value
      else
        dob = string_value
      end
    else
      dob = string_value
    end
    self.birthdate=dob
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

  def validate_date_of_birth_age
    if birthdate < Date.parse("1900-01-01")
      errors.add(:date_of_birth, :too_old)
    end    
  end
  
  def validate_date_of_birth
    if birthdate_before_type_cast.is_a?(Date) || birthdate_before_type_cast.is_a?(Time)
      validate_date_of_birth_age
      return
    end
    if birthdate_before_type_cast.blank?
      if date_of_birth_parts.compact.length == 3
        errors.add(:date_of_birth, :invalid)
      else
        errors.add(:date_of_birth, :blank)
      end
    else
      @raw_date_of_birth = birthdate_before_type_cast
      date = nil
      if matches = birthdate_before_type_cast.to_s.match(/\A(\d{1,2})\D+(\d{1,2})\D+(\d{4})\z/)
        m,d,y = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      elsif matches = birthdate_before_type_cast.to_s.match(/\A(\d{4})\D+(\d{1,2})\D+(\d{1,2})\z/)
        y,m,d = matches.captures
        date = Date.civil(y.to_i, m.to_i, d.to_i) rescue nil
      end
      if date
        @raw_date_of_birth = nil
        self[:birthdate] = date
        validate_date_of_birth_age
      else
        errors.add(:date_of_birth, :format)
      end
    end
  end
end
