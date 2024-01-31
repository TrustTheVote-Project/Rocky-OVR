class CatalistLookup < ActiveRecord::Base
  include DateOfBirthMethods
  include CatalistLookupReportingMethods
  include UidGenerator
  include TrackableMethods
  
  has_one :abrs_catalist_lookup
  has_one :abr, through: :abrs_catalist_lookup

  has_one :catalist_lookups_registrant
  has_one :registrant, through: :catalist_lookups_registrant, primary_key: :uid, foreign_key: :registrant_uid

  belongs_to :partner, optional: true

  serialize :match, Hash
  
  belongs_to :state,    :class_name => "GeoState", optional: true

  validates_presence_of :first
  validates_presence_of :last
  validates_presence_of :birthdate
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :zip
  validates_presence_of :email
  validates_format_of   :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
  validates_presence_of :phone_type, if: -> { !phone.blank? }
  
  before_validation :clean_phone_number

  validates_format_of :phone, with: /\A(?!([0-9])\1{9})[1-9]\d{2}[-\s]*\d{3}[-\s]*\d{4}\z/, allow_blank: true

  def clean_phone_number
    self.phone = phone.gsub(/[^\d]/, '') if phone.present?
  end

  
  validate :validate_date_of_birth
  validate :validates_zip
  validate :validate_phone_present_if_opt_in_sms

  def validate_phone_present_if_opt_in_sms
    if (self.opt_in_sms? || self.partner_opt_in_sms?) && self.phone.blank?
      self.errors.add(:phone, :required_if_opt_in)
    end
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
    if birthdate > Date.today
      errors.add(:date_of_birth, :future)      
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

  ADDRESS_FIELDS = ["address"]

  CITY_FIELDS = ["city"]

  NAME_FIELDS = ["first", 
   "last",]

  PDF_FIELDS = [
    "zip",
    "first", 
    "last", 
    "address",
    "city", 
  ]
  
  def self.validate_fields(list, regex, message)
    list.each do |field|
      validates field, format: { with: regex , 
        message: message }#I18n.t('activerecord.errors.messages.invalid_for_pdf')}
    end    
  end

  validate_fields(PDF_FIELDS, Registrant::OVR_REGEX, :invalid_for_pdf)
  validate_fields(NAME_FIELDS, Registrant::OVR_REGEX, :invalid)
  validate_fields(ADDRESS_FIELDS, Registrant::CA_ADDRESS_REGEX, "Valid characters are: A-Z a-z 0-9 # dash space comma forward-slash period")

  
  def self.find_by_param(param)
    lookup = find_by_uid(param)
    raise AbandonedRecord.new(lookup) if lookup && lookup.abandoned?
    lookup
  end

  def self.find_by_param!(param)
    find_by_param(param) || begin raise ActiveRecord::RecordNotFound end
  end
  
  def to_param
    uid
  end


  def any_email_opt_ins?
    collect_email_address? && (partner.rtv_email_opt_in || partner.primary? || partner.partner_email_opt_in)
  end
  
  def any_phone_opt_ins?
    partner.rtv_sms_opt_in || partner.partner_sms_opt_in? || partner.primary?
  end

  


  def to_catalist_params
    {
      first: first,
      last: last,
      address: address,
      city: city,
      state: state_abbrev,
      zip: zip,
      birthdate: format_birthdate(birthdate)
    }
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

  def suffixes
    Registrant::SUFFIX_KEYS.collect {|key| I18n.t("txt.registration.suffixes.#{key}", :locale=>locale)}
  end
  def phone_types
    Registrant::PHONE_TYPE_KEYS.collect {|key| I18n.t("txt.registration.phone_types.#{key}", :locale=>locale)}
  end
  
  def use_state_flow?
    false
  end
  
  def use_short_form?
    true
  end
  
  def require_email_address?
    true
  end

  def collect_email_address?
    true
  end

  def abandoned?
    false
  end

  def locale
    "en"
  end

  def state_abbrev
    state && state.abbreviation
  end
  def state_name
    state && state.name
  end
  def state_system_name
    name = state&.online_registration_system_name
    if state && !name
      name = I18n.t("states.online_registration_system_name", locale: locale, state_name: state_name)
    end
    name      
  end

  def zip=(zip)
    self[:zip] = zip
    if zip && !zip.blank?
      self.state_id = (s = GeoState.for_zip_code(zip.strip)) ? s.id : self.state_id
    end
  end

  def lookup!
    service = CatalistService.new
    self.match = service.retrieve(abr: abr, params: to_catalist_params)
    self.save
  end
  
  def is_match?
    return !matched_data.nil?
  end
  
  # {"count"=>1,
  #  "mrPersons"=>
  #   [{"dwid"=>"1231231",
  #     "matchRate"=>1.0,
  #     "distanceScore"=>nil,
  #     "distance"=>nil,
  #     "matchMethod"=>nil,
  #     "firstname"=>"A",
  #     "middlename"=>"M",
  #     "lastname"=>"M",
  #     "namesuffix"=>nil,
  #     "gender"=>"male",
  #     "birthdate"=>"XXXX-XX-XX",
  #     "regaddrline1"=>"XXXX",
  #     "regaddrline2"=>"",
  #     "regaddrcity"=>"XXXX",
  #     "regaddrstate"=>"XX",
  #     "regaddrzip"=>"XXXXX",
  #     "mailaddrline1"=>"XXXXX",
  #     "mailaddrline2"=>"",
  #     "mailaddrcity"=>"XXXX",
  #     "mailaddrstate"=>"XX",
  #     "mailaddrzip"=>"XXXXX",
  #     "phone"=>nil,
  #     "voterstatus"=>"active", #active, inactive, multipleAppearances, unregistered, unmatchedMember;
  #     "additionalProperties"=>{}}],
  #  "matchMethod"=>"STANDARD", #  standard, name, name-address, distance, email, phon 
  #  "status"=>"OK"}
  # {"count"=>0, "mrPersons"=>[], "matchMethod"=>"STANDARD", "status"=>"OK"} 
  def matched_data
    lookup! if self.match.blank?
    return nil if match["count"] == 0 || match["mrPersons"].blank? || match["mrPersons"].length == 0
    match["mrPersons"].each do |person|
      return person if person["voterstatus"] == "active"
    end
    return nil
  end
  
  def match_name
    matched_data && "#{matched_data["firstname"]} #{matched_data["middlename"]} #{matched_data["lastname"]}"
  end
  def match_address1
    matched_data && "#{matched_data["regaddrline1"]}"
  end
  def match_address2
    matched_data && "#{matched_data["regaddrline2"]}"
  end
  def match_city
    matched_data && "#{matched_data["regaddrcity"]}"
  end
  def match_state
    matched_data && "#{matched_data["regaddrstate"]}"
  end
  def match_zip
    matched_data && "#{matched_data["regaddrzip"]}"
  end
  
  
  
  def state_abbrev
    state && state.abbreviation
  end
  def state_name
    state && state.name
  end
  
  def to_abr
    addr_parts = address.to_s.split(" ")
    street_number = addr_parts.shift
    street_name = addr_parts.join(" ")
    abr = Abr.new({
      partner_id: partner_id,
      tracking_source: tracking_source,
      tracking_id: tracking_id,
      first_name: first,
      last_name: last,
      name_suffix: suffix,
      street_number: street_number,
      street_name: street_name,
      city: city,
      zip: zip,
      home_state_id: state_id,
      email: email,
      phone: phone,
      phone_type: phone_type,
      date_of_birth: date_of_birth,
      opt_in_email: opt_in_email,
      opt_in_sms: opt_in_sms,
      partner_opt_in_email: partner_opt_in_email,
      partner_opt_in_sms: partner_opt_in_sms,

    })
    abr.current_step = "2"
    abr
  end
  
  def to_registrant
    registrant = Registrant.new({
      partner_id: partner_id,
      tracking_source: tracking_source,
      tracking_id: tracking_id,
      first_name: first,
      last_name: last,
      name_suffix: suffix,
      home_address: address,
      home_city: city,
      home_zip_code: zip,
      home_state_id: state_id,
      email_address: email,
      phone: phone,
      phone_type: phone_type,      
      date_of_birth: date_of_birth,
      opt_in_email: opt_in_email,
      opt_in_sms: opt_in_sms,
      partner_opt_in_email: partner_opt_in_email,
      partner_opt_in_sms: partner_opt_in_sms,
    
    })
    registrant.locale = locale
    registrant.short_form = true
    registrant.status = :step_1
    registrant
  end

  def state_last_updated_days
    date = (state && state.catalist_updated_at) || 14.days.ago
    (DateTime.now.to_date - date.to_date).to_i
  end

  def state_last_updated_at
    date = (state && state.catalist_updated_at) || 3.months.ago
  end

  private 
  def format_birthdate(date)
    self.class.format_birthdate(date)
  end
  def self.format_birthdate(date)
    return date.strftime("%m%d%Y")
  end
  
  
end
