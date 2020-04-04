# encoding: utf-8

#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class Registrant < ActiveRecord::Base
  class AbandonedRecord < StandardError
    attr_reader :registrant
    def initialize(registrant)
      @registrant = registrant
    end
    
  end

  include AASM
  include Lolrus
  include Rails.application.routes.url_helpers
  include RegistrantMethods
  include TimeStampHelper
  
  has_many :ab_tests
  
  serialize :state_ovr_data, Hash

  STEPS = [:initial, :step_1, :step_2, :step_3, :step_4, :step_5, :complete]
  def step_list
    STEPS
  end
  TITLE_KEYS = I18n.t('txt.registration.titles', :locale => :en).keys
  SUFFIX_KEYS = I18n.t('txt.registration.suffixes', :locale => :en).keys
  RACE_KEYS = I18n.t('txt.registration.races', :locale => :en).keys
  PHONE_TYPE_KEYS = I18n.t('txt.registration.phone_types', :locale => :en).keys

  TITLES = RockyConf.enabled_locales.collect{|l| TITLE_KEYS.collect{|key| I18n.t("txt.registration.titles.#{key}", :locale => l) } }.flatten
  SUFFIXES = RockyConf.enabled_locales.collect{|l| SUFFIX_KEYS.collect{|key| I18n.t("txt.registration.suffixes.#{key}", :locale => l) } }.flatten
  REMINDER_EMAILS_TO_SEND = 2
  REMINDER_EMAIL_PRIORITY = 0
  WRAP_UP_PRIORITY = REMINDER_EMAIL_PRIORITY + 1


  ADDRESS_FIELDS = ["home_address", 
    "mailing_address", 
    "prev_address"]

  CITY_FIELDS = ["home_city", 
   "mailing_city", 
   "prev_city"]

  NAME_FIELDS = ["first_name", 
   "middle_name", 
   "last_name",
   "prev_first_name", 
   "prev_middle_name", 
   "prev_last_name"]

  PDF_FIELDS = [
      "home_zip_code",
       "first_name", 
       "middle_name", 
       "last_name", 
       "home_address", 
       "home_unit", 
       "home_city", 
       "mailing_address", 
       "mailing_unit", 
       "mailing_city", 
       "mailing_zip_code", 
       "prev_first_name", 
       "prev_middle_name", 
       "prev_last_name", 
       "prev_address", 
       "prev_unit", 
       "prev_city", 
       "prev_zip_code"
    ]
  
  OVR_REGEX = /\A(\p{Latin}|\P{Letter})*\z/
  
  #CA_NAME_REGEX =   /\A[a-zA-Z0-9'#,\-\/_\.@\s]*\z/ #A-Z a-z 0-9 '#,-/_ .@space
  
  # CA_EMAIL_REGEX =  /\A[a-zA-Z0-9\-\/_\.]+@.*\..*\z/ #A-Z a-z 0-9, underscore, dash, and '@' followed by at least one "."
  CA_ADDRESS_REGEX    = /\A[a-zA-Z0-9#\-\s,\/\.]*\z/ # A-Z a-z 0-9 # dash space, / .
  CITY_STATE_REGEX = /\A[a-zA-Z0-9#\-\s'\.]*\z/      # A-Z a-z 0-9 # dash space ' .
  CA_CITY_STATE_REGEX = /\A[a-zA-Z0-9#\-\s]*\z/      # A-Z a-z 0-9 # dash space
  # OVR_REGEX = /\A[a-zA-Z0-9#\-\s,\/\.\+!@\$%\^&\*_=\(\)\[\]\{\};':"\\<>\?\|]*\z/
  #white space and hyphen for names; and for addresses phone#s and other stuff, also include special chars such as # ( ) / + 
  
  def self.validate_fields(list, regex, message)
    list.each do |field|
      validates field, format: { with: regex , 
        message: message }#I18n.t('activerecord.errors.messages.invalid_for_pdf')}
    end
    
  end
  
  #before_validation :basic_character_replacement
  SPANISH_CHARS = "áéíóúñ"
  def basic_character_replacement!
    [ADDRESS_FIELDS, CITY_FIELDS].flatten.each do |field|
      val = self.send(field).to_s
      val = val.gsub(/á/i,"a").gsub(/é/i,"e").gsub(/í/i,"i").gsub(/ó/i,"o").gsub(/ú/i,"u").gsub(/ñ/i,"n")
      self.send("#{field}=", val)
    end
    [CITY_FIELDS].flatten.each do |field|
      #Also allow city fields to have the same as address fields (, / .) - just remove them
      val = self.send(field).to_s
      val = val.gsub(/[,\.]/i,"").gsub(/\//i, " ")
      self.send("#{field}=", val)      
    end
  end
  
  
  validate_fields(PDF_FIELDS, OVR_REGEX, :invalid_for_pdf)
  validate_fields(NAME_FIELDS, OVR_REGEX, :invalid)
  validate_fields(ADDRESS_FIELDS, CA_ADDRESS_REGEX, "Valid characters are: A-Z a-z 0-9 # dash space comma forward-slash period")
  # Moved this validation to registrant_validator for CA-only addresses 
  #validate_fields(CITY_FIELDS, CA_CITY_STATE_REGEX, :invalid)
  
  # PDF_FIELDS.each do |pdf_field|
  #   validates pdf_field, format: { with: OVR_REGEX , 
  #     message: :invalid_for_pdf }#I18n.t('activerecord.errors.messages.invalid_for_pdf')}
  # end
  
  
  
  

  FINISH_IFRAME_URL = "https://s3.rockthevote.com/rocky/rtv-ovr-share.php"

  CSV_HEADER = [
    "Status",
    "Tracking Source",
    "Tracking ID",
    "Open Tracking ID",
    "State API Submission Result",
    "Language",
    "Date of birth",
    "Email address",
    "US citizen?",
    "Salutation",
    "First name",
    "Middle name",
    "Last name",
    "Name suffix",
    "Home address",
    "Home unit",
    "Home city",
    "Home County",
    "Home state",
    "Home zip code",
    "Has mailing address?",
    "Mailing address",
    "Mailing unit",
    "Mailing city",
    "Mailing County",
    "Mailing state",
    "Mailing zip code",
    "Party",
    "Race",
    "Phone",
    "Phone type",
    "Opt-in to RTV email?",
    "Opt-in to RTV sms?",
    "Opt-in to Partner email?",
    "Opt-in to Partner SMS/robocall",
    "Survey question 1",
    "Survey answer 1",
    "Survey question 2",
    "Survey answer 2",
    "Volunteer for RTV",
    "Volunteer for partner",
    "Ineligible reason",
    "Pre-Registered",
    "Started registration",
    "Finish with State",
    "Built via API",
    "Has State License",
    "Has SSN",
    "VR Application Submission Modifications",
    "VR Application Submission Errors",    
    "VR Application Status",
    "VR Application Status Details",
    "VR Application Status Imported DateTime",
    "Submitted Via State API",
    "Submitted Signature to State API"
  ]
  
  GROMMET_CSV_HEADER = [
    "Status",
    "Potential Duplicate?",
    "Shift ID",
    "Canvasser Name",
    "Event Zip",
    "Event Name",
    
    "Tablet ID",
    
    "State API Submission Result",
    "Language of Form",    
    "Date of birth",
    "Email address",
    "Over 18 affirmation",

    
    "US citizen affirmation",
    "Salutation",
    "First name",
    "Middle name",
    "Last name",
    "Name suffix",
    "Home address",
    "Home unit",
    "Home city",
    "Home County",
    "Home state",
    "Home zip code",
    "Has mailing address?",
    "Mailing address",
    "Mailing unit",
    "Mailing city",
    "Mailing County",
    "Mailing state",
    "Mailing zip code",
    
    "Preferred Language",
    
    "Party",
    "Race",
    
    "Mobile Phone",
    "Home Phone",
    "Work Phone",
    
    "Opt-in to Partner email?",
    "Opt-in to Partner SMS/robocall",
    "Volunteer for partner",
    "Started registration",
    "Has State License",
    "Has SSN",
    
    "Submitted Signature",
    "Geo Location",
    
    "VR Application Submission Modifications",
    "VR Application Submission Errors",    
    "VR Application Status",
    "VR Application Status Details",
    "VR Application Status Imported DateTime",
    "Internal Registrant ID",
    
  ]



  
  
  
  attr_protected :status, :uid, :created_at, :updated_at, :abandoned, :pdf_downloaded_at, :final_remiinder_delivered

  aasm column: :status do
    state :initial, initial: true
    state :step_1
    state :step_2, :enter => :generate_barcode
    state :step_3
    state :step_4
    state :step_5
    state :complete, :enter => :complete_registration
    state :under_18
    state :rejected
    
    event :save_or_reject do
      transitions :to => :rejected, :from => Registrant::STEPS, :guard => :ineligible?
      [:step_1, :step_2, :step_3, :step_4, :step_5].each do |step|
        transitions :to => step, :from => step
      end
    end

    event :advance_to_step_1 do
      transitions :to => :step_1, :from => [:initial, :step_1, :step_2, :step_3, :step_4, :rejected]
    end

    event :advance_to_step_2 do
      transitions :to => :step_2, :from => [:step_1, :step_2, :step_3, :step_4, :rejected]
    end

    event :advance_to_step_3 do
      transitions :to => :step_3, :from => [:step_2, :step_3, :step_4, :rejected]
    end

    event :advance_to_step_4 do
      transitions :to => :step_4, :from => [:step_3, :step_4, :rejected]
    end

    event :advance_to_step_5 do
      transitions :to => :step_5, :from => [:step_4, :step_5, :rejected]
    end

    event :complete do
      transitions :to => :complete, :from => [:step_5]
    end

    event :request_reminder do
      transitions :to => :under_18, :from => [:rejected, :step_1]
    end
    
  end

  belongs_to :partner
  
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :prev_state,    :class_name => "GeoState"

  has_one :registrant_status
  has_one :pdf_delivery

  delegate :requires_race?, :requires_party?, :require_age_confirmation?, :require_id?, :to => :home_state, :allow_nil => true

  def self.state_attr_accessor(*args)
    [args].flatten.each do |arg|
      define_method(arg) do
        state_ovr_data[arg]
      end
      define_method("#{arg}=") do |val|
        state_ovr_data[arg] = val
      end
    end
  end
  

  def self.validates_zip_code(*attr_names)
    configuration = { }
    configuration.update(attr_names.extract_options!)

    validates_presence_of(attr_names, configuration)
    validates_format_of(attr_names, configuration.merge(:with => /\A\d{5}(-\d{4})?\z/, :allow_blank => true));

    validates_each(attr_names, configuration) do |record, attr_name, value|
      if record.errors[attr_name].empty? && !GeoState.valid_zip_code?(record.send(attr_name))
        record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
      end
    end
  end

  before_validation :clear_superfluous_fields
  before_validation :reformat_state_id_number
  before_validation :reformat_phone
  before_validation :set_opt_in_email

  after_validation :calculate_age
  after_validation :set_official_party_name
  after_validation :check_ineligible
  after_validation :enqueue_tell_friends_emails

  before_create :generate_uid
  before_create :set_dl_defaults

  before_save :set_questions, :set_finish_with_state, :set_will_be_18, :limit_zip_codes

  attr_accessor :telling_friends, :new_locale, :input_locale

  validates_with RegistrantValidator
  

  def skip_survey_and_opt_ins?
    question_1.blank? && question_2.blank? && !any_ask_for_volunteers? && !any_email_opt_ins? && !any_phone_opt_ins?
  end
  
  def locale_english_name
    I18n.t("locales.#{locale}.name", locale: "en")
  end

  def question_1
    partner.send("survey_question_1_#{self.locale}")
  end
  def question_2
    partner.send("survey_question_2_#{self.locale}")
  end

  def collect_email_address?
    collect_email_address.to_s.downcase.strip != 'no'
  end
  
  def any_email_opt_ins?
    collect_email_address? && (partner.rtv_email_opt_in || partner.primary? || partner.partner_email_opt_in)
  end
  
  def any_phone_opt_ins?
    partner.rtv_sms_opt_in || partner.partner_sms_opt_in? || partner.primary?
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
  
  def not_require_email_address?
    !require_email_address?
  end
  
  def require_email_address?
    #!%w(no optional)
    !%w(no).include?(collect_email_address.to_s.downcase.strip) && !(home_state && !home_state.participating?)
  end

  def needs_mailing_address?
    at_least_step_2? && has_mailing_address?
  end

  def needs_prev_name?
    (at_least_step_2? || (at_least_step_2? && use_short_form?)) && change_of_name?
  end

  def needs_prev_address?
    (at_least_step_2? || (at_least_step_2? && use_short_form?)) && change_of_address?
  end

  attr_accessor :api_version
  # Builds the record from the API data and sets the correct state
  def self.build_from_api_data(data, api_finish_with_state = false)
    r = Registrant.new(data)
    r.partner_opt_in_sms = false unless r.partner && (r.partner.primary? || r.partner.partner_sms_opt_in)
    r.building_via_api_call   = true
    r.finish_with_state       = api_finish_with_state
    r.has_state_license = true if api_finish_with_state
    r.status                  = api_finish_with_state ? :step_2 : :step_5
    r
  end

  def self.build_from_pa_api_data(data)
    r = Registrant.new(data)
    r.building_via_api_call   = true
    r.finish_with_state       = true
    r.status                  = :step_2
    # Check for validity
    if !r.valid?
      if r.errors[:email_address] && r.errors[:email_address].any?
        r.collect_email_address = 'no'
        r.email_address = nil
      end
      if r.errors[:phone] && r.errors[:phone].any?
        r.phone = nil
        r.phone_type = nil
      end
    end
    r
  end


  def self.find_by_param(param)
    reg = find_by_uid(param)
    raise AbandonedRecord.new(reg) if reg && reg.abandoned?
    reg
  end

  def self.find_by_param!(param)
    find_by_param(param) || begin raise ActiveRecord::RecordNotFound end
  end
  
  def self.remove_fake_records
    Registrant.where(is_fake: true).where(status: 'complete').destroy_all
  end
  
  def self.abandon_stale_records
    id_list = []
    uid_list = []
    pa_registrants = {}
    va_registrants = {}
    mi_registrants = {}
    distribute_reads do 
      both_ids = self.where("(abandoned != ?) AND (status != 'complete') AND (updated_at < ?)", true, RockyConf.minutes_before_abandoned.minutes.seconds.ago).pluck(:id, :uid) 
      both_ids.each do |id, uid|
        id_list << id
        uid_list << uid
      end      
      StateRegistrants::PARegistrant.where(registrant_id: uid_list).find_each {|sr| pa_registrants[sr.registrant_id] = sr}
      StateRegistrants::VARegistrant.where(registrant_id: uid_list).find_each {|sr| va_registrants[sr.registrant_id] = sr}
      StateRegistrants::MIRegistrant.where(registrant_id: uid_list).find_each {|sr| va_registrants[sr.registrant_id] = sr}
    
      self.where(["id in (?)", id_list]).find_each(:batch_size=>500) do |reg|
        #StateRegistrants::PARegistrant
        if reg.use_state_flow?
          sr  = nil
          case reg.home_state_abbrev
          when "PA"
            sr = pa_registrants[reg.uid] || StateRegistrants::PARegistrant.new
          when "VA"
            sr = va_registrants[reg.uid] || StateRegistrants::VARegistrant.new
          when "MI"
            sr = mi_registrants[reg.uid] || StateRegistrants::MIRegistrant.new
          end
          reg.instance_variable_set(:@existing_state_registrant, sr)
        end
        if reg.finish_with_state?
          reg.status = "complete"
          begin
            reg.deliver_thank_you_for_state_online_registration_email
          rescue Exception => e
            Rails.logger.error(e)
            # raise e
          end
        else 
          # Send chase email
          begin
            reg.deliver_chaser_email
          rescue Exception => e
            Rails.logger.error(e)
          end
        end
        reg.abandon!
        Rails.logger.info "Registrant #{reg.id} abandoned at #{Time.now}"
        if reg.is_fake?
          reg.destroy
        end      
      end
    end
  end

  ### instance methods
  attr_accessor :attest_true

  def to_param
    uid
  end

  def localization
    home_state_id && locale ?
        StateLocalization.where({:state_id  => home_state_id, :locale => locale}).first : nil
  end
  
  def en_localization
    home_state_id ? StateLocalization.where({:state_id  => home_state_id, :locale => 'en'}).first : nil
      
  end


  def clear_superfluous_fields
    unless has_mailing_address?
      self.mailing_address = nil
      self.mailing_unit = nil
      self.mailing_city = nil
      self.mailing_state = nil
      self.mailing_zip_code = nil
    end
    unless change_of_name?
      self.prev_name_title = nil
      self.prev_first_name = nil
      self.prev_middle_name = nil
      self.prev_last_name = nil
      self.prev_name_suffix = nil
    end
    unless change_of_address?
      self.prev_address = nil
      self.prev_unit = nil
      self.prev_city = nil
      self.prev_state = nil
      self.prev_zip_code = nil
    end
    # self.race = nil unless requires_race?
    self.party = nil unless requires_party?
  end

  def reformat_state_id_number
    self.state_id_number.upcase! if self.state_id_number.present? && self.state_id_number_changed?
  end

  def reformat_phone
    if phone.present? && phone_changed?
      digits = phone_digits
      if digits.length == 10
        self.phone = [digits[0..2], digits[3..5], digits[6..9]].join('-')
      end
    end
  end
  
  def phone_digits
    phone.to_s.gsub(/\D/,'')
  end
  
  def set_opt_in_email
    if !require_email_address? && email_address.blank?
      self.opt_in_email = false
    end
    return true
  end




  def calculate_age
    if errors[:date_of_birth].empty? && !date_of_birth.blank?
      now = (created_at || Time.now).to_date
      years = now.year - date_of_birth.year
      if (date_of_birth.month > now.month) || (date_of_birth.month == now.month && date_of_birth.day > now.day)
        years -= 1
      end
      self.age = years
    else
      self.age = nil
    end
  end
  
  def titles
    TITLE_KEYS.collect {|key| I18n.t("txt.registration.titles.#{key}", :locale=>locale)}
  end

  def suffixes
    SUFFIX_KEYS.collect {|key| I18n.t("txt.registration.suffixes.#{key}", :locale=>locale)}
  end

  def races
    RACE_KEYS.collect {|key| I18n.t("txt.registration.races.#{key}", :locale=>locale)}
  end
  
  def phone_types
    PHONE_TYPE_KEYS.collect {|key| I18n.t("txt.registration.phone_types.#{key}", :locale=>locale)}
  end

  def name_title_key
    key_for_attribute(:name_title, 'titles')
  end
  def english_name_title
    english_attribute_value(name_title_key, 'titles')
  end
  
  def name_suffix_key
    key_for_attribute(:name_suffix, 'suffixes')
  end
  def english_name_suffix
    english_attribute_value(name_suffix_key, 'suffixes')
  end
    
  def prev_name_title_key
    key_for_attribute(:prev_name_title, 'titles')
  end
  def english_prev_name_title
    english_attribute_value(prev_name_title_key, 'titles')
  end

  def prev_name_suffix_key
    key_for_attribute(:prev_name_suffix, 'suffixes')
  end
  def english_prev_name_suffix
    english_attribute_value(prev_name_suffix_key, 'suffixes')
  end
  
  
  def self.english_races
    I18n.t('txt.registration.races', :locale=>:en).values
  end

  def self.english_race(locale, race)
    if english_races.include?(race)
      return race
    else
      if ridx = race_idx(locale, race)
        return I18n.t('txt.registration.races', :locale=>:en).values[ridx]
      else
        return nil
      end
    end
  end
  
  def self.race_key(locale, race)
    if ridx = race_idx(locale, race)
      I18n.t('txt.registration.races').keys[ridx]
    else
      nil
    end
  end
  
  def self.race_idx(locale, race)
    I18n.t('txt.registration.races', :locale=>locale).values.collect(&:downcase).index(race.to_s.downcase)
  end

  # Reset name/prev prefix, suffix, race, party, phone_type
  def check_locale_change
    if !self.new_locale.blank? && self.new_locale != self.locale
      selected_name_title_key = name_title_key
      selected_name_suf_key = name_suffix_key
      selected_prev_name_title_key = prev_name_title_key
      selected_prev_name_suf_key = prev_name_suffix_key
      selected_race_key = race_key
      party_idx = state_parties.index(self.party)
      selected_phone_key = phone_type_key
      
      self.locale = self.new_locale
      
      self.name_title=I18n.t("txt.registration.titles.#{selected_name_title_key}", locale: self.locale) if selected_name_title_key
      self.name_suffix=I18n.t("txt.registration.suffixes.#{selected_name_suf_key}", locale: self.locale) if selected_name_suf_key
      self.prev_name_title=I18n.t("txt.registration.titles.#{selected_prev_name_title_key}", locale: self.locale) if selected_prev_name_title_key
      self.prev_name_suffix=I18n.t("txt.registration.suffixes.#{selected_prev_name_suf_key}", locale: self.locale) if selected_prev_name_suf_key
      self.race = I18n.t("txt.registration.races.#{selected_race_key}", locale: self.locale) if selected_race_key
      self.party = state_parties[party_idx] if !party_idx.nil?
      self.phone_type=I18n.t("txt.registration.phone_types.#{selected_phone_key}", locale: self.locale) if selected_phone_key
      self.save(validate: false)
    end
  end

  def pdf_date_of_birth_month
    pdf_date_of_birth.split('/')[0]
  end
  def pdf_date_of_birth_day
    pdf_date_of_birth.split('/')[1]
  end
  def pdf_date_of_birth_year
    pdf_date_of_birth.split('/')[2]
  end
  
  def pdf_date_of_birth
    (date_of_birth.is_a?(Date) || date_of_birth.is_a?(DateTime)) ? date_of_birth.to_s(:month_day_year) : date_of_birth.to_s
  end

  def pdf_english_race
    if race != I18n.t('txt.registration.races', :locale=>locale).values.last
      english_race
    else
      ""
    end
  end
  
  def pdf_race
    if race != I18n.t('txt.registration.races', :locale=>locale).values.last
      race
    else
      ""
    end
  end

  def pdf_barcode
    user_code = id.to_s(36).rjust(6, "0")
    "*#{RockyConf.sponsor.barcode_prefix}-#{user_code}*".upcase
  end
  
  def pdf_assistant_info
    return nil unless state_registrant
    return state_registrant.pdf_assistant_info
  end

  def state_id_tooltip
    localization.id_number_tooltip
  end

  def race_tooltip
    localization.race_tooltip
  end

  def party_tooltip
    localization.party_tooltip
  end

  def home_state_not_participating_text
    localization.not_participating_tooltip
  end
  
  def registration_deadline
    localization.registration_deadline
  end
  
  def state_registrar_address
    home_state && home_state.registrar_address(self.home_zip_code)
  end
  
  [:pdf_instructions, :email_instructions, :pdf_other_instructions].each do |state_data|
    define_method("home_state_#{state_data}") do
      localization.send(state_data)
    end
  end
  
  def registration_instructions_url
    ((partner.blank? || partner.registration_instructions_url.blank?) ? RockyConf.pdf.nvra.page1.other_block.instructions_url : partner.registration_instructions_url).tap do |r_url|
      return r_url.gsub(
        "<LOCALE>",locale.to_s
      ).gsub("<STATE>",home_state_abbrev.to_s)
    end
  end

  def under_18_instructions_for_home_state
    I18n.t('txt.registration.instructions.under_18',
            :state_name => home_state.name,
            :state_rule => localization.sub_18).html_safe
  end


  def abandon!
    self.abandoned = true
    self.state_id_number = nil
    self.save(:validate=>false)
    if self.state_registrant
      self.state_registrant.cleanup!
    end
  rescue    
  end

  # def advance_to!(next_step, new_attributes = {})
  #   self.attributes = new_attributes
  #   current_status_number = STEPS.index(aasm.current_state)
  #   next_status_number = STEPS.index(next_step)
  #   status_number = [current_status_number, next_status_number].max
  #   send("advance_to_#{STEPS[status_number]}!")
  # end

  def home_zip_code=(zip)
    self[:home_zip_code] = zip
    if zip && !zip.blank?
      self.home_state = nil
      self.home_state_id = (s = GeoState.for_zip_code(zip.strip)) ? s.id : self.home_state_id
    end
  end

  def home_state_name
    home_state && home_state.name
  end
  def home_state_system_name
    name = home_state&.online_registration_system_name
    if home_state && !name
      name = I18n.t("states.online_registration_system_name", locale: locale, state_name: home_state_name)
    end
    name      
  end
  
  def home_state_abbrev
    home_state && home_state.abbreviation
  end
  
  def home_state_online_reg_url
    home_state && home_state.online_reg_url(self)
  end
  
  def has_home_state_online_redirect?
    home_state && home_state.redirect_to_online_reg_url(self)
  end
  
  def has_ovr_pre_check?
    in_ovr_flow? && home_state_has_ovr_pre_check?
  end
  
  def home_state_has_ovr_pre_check?
    home_state ? home_state.has_ovr_pre_check?(self) : false
  end

  def ovr_pre_check(controller = nil)
    home_state ? home_state.ovr_pre_check(self, controller) : nil
  end

  def decorate_for_state(controller = nil)
    home_state ? home_state.decorate_registrant(self, controller) : nil
  end
  
  def mailing_state_abbrev=(abbrev)
    self.mailing_state = GeoState[abbrev]
  end

  def mailing_state_abbrev
    mailing_state && mailing_state.abbreviation
  end
  
  def mailing_state_name
    mailing_state && mailing_state.name
  end

  def prev_state_abbrev=(abbrev)
    self.prev_state = GeoState[abbrev]
  end

  def prev_state_abbrev
    prev_state && prev_state.abbreviation
  end

  def prev_state_name
    prev_state && prev_state.name
  end

  def home_state_online_reg_enabled?
    !home_state.nil? && home_state.online_reg_enabled?(locale, self)
  end
  
  def in_ovr_flow?
    home_state_allows_ovr?
  end
  
  def home_state_allows_ovr?
    localization ? localization.allows_ovr?(self) : false
  end
  
  def home_state_allows_ovr_ignoring_license?
    localization ? localization.allows_ovr_ignoring_license?(self) : false
  end
  
  def skip_state_flow!
    self.state_ovr_data ||= {}
    self.state_ovr_data[:skip_state_flow] = true
    self.finish_with_state = false
    self.save(validate: false)
  end
  
  def state_flow_error?
    skip_state_flow? && state_registrant && state_registrant.submitted?
  end
  
  def custom_state_flow_error_message
    state_flow_error? && state_registrant.custom_state_flow_error_message
  end
  
  def skip_state_flow?
    h = self.state_ovr_data || {}
    !!h[:skip_state_flow]
  rescue
    false
  end
  
  def use_state_flow?
    home_state && home_state.use_state_flow?(self)
  end
  
  def submitted_via_state_api?
     (!skip_state_flow? && existing_state_registrant && existing_state_registrant.submitted?) || is_grommet?
  end
  
  def first_registration?
    if is_grommet? 
      pa_adapter = VRToPA.new(self.state_ovr_data["voter_records_request"])
      return pa_adapter.is_new_registration_boolean
    elsif existing_state_registrant
      return existing_state_registrant.first_registration?
    else
      return !!self.first_registration
    end    
  end
  
  def first_registration?
    if is_grommet? 
      pa_adapter = VRToPA.new(self.state_ovr_data["voter_records_request"])
      return pa_adapter.is_new_registration_boolean
    elsif existing_state_registrant
      return existing_state_registrant.first_registration?
    else
      return !!self.first_registration
    end    
  end
  
  def canvasser_name
    return nil if !is_grommet?
    @canvasser_id ||= self.tracking_source
    t = TrackingEvent.where(source_tracking_id: @canvasser_id, tracking_event_name: "pa_canvassing_clock_in").first
    t && t.tracking_data ? t.tracking_data["canvasser_name"] : nil    
  end
  
  def canvasser_clock_in
    return nil if !is_grommet?
    @canvasser_id ||= self.tracking_source
    t = TrackingEvent.where(source_tracking_id: @canvasser_id, tracking_event_name: "pa_canvassing_clock_in").first
    t && t.tracking_data ? t.tracking_data["clock_in_datetime"] : nil
  end

  def canvasser_clock_out
    return nil if !is_grommet?
    @canvasser_id ||= self.tracking_source
    t = TrackingEvent.where(source_tracking_id: @canvasser_id, tracking_event_name: "pa_canvassing_clock_out").first
    t && t.tracking_data ? t.tracking_data["clock_out_datetime"] : nil    
  end
  
  def tablet_id
    return nil if !is_grommet?
    @canvasser_id ||= self.tracking_source
    t = TrackingEvent.where(source_tracking_id: @canvasser_id, tracking_event_name: "pa_canvassing_clock_in").first
    t && t.tracking_data ? t.tracking_data["device_id"] : nil    
  end
  
  
  def grommet_submission
    begin 
      state_ovr_data["voter_records_request"]["voter_registration"]
    rescue
      nil
    end
  end
  
  def is_grommet?
    !grommet_submission.blank?
  end
  
  def api_submitted_with_signature
    return nil if !is_grommet? # Right now sigs only come from grommet
    return !grommet_submission["signature"].blank?    
  end
  
  def api_submission_status
    return nil if !submitted_via_state_api?
    if is_grommet?
      if state_ovr_data["pa_transaction_id"].blank?
        if state_ovr_data["errors"] && state_ovr_data["errors"].any?
          return ["Error", state_ovr_data["errors"] ? state_ovr_data["errors"][0] : nil].join(": ")
        elsif djid = state_ovr_data["delayed_job_id"]
          begin
            j = Delayed::Job.find(djid)
            return "Queued: #{j.run_at.in_time_zone('Eastern Time (US & Canada)')}"
          rescue
            return "Unknown"
          end
        else
          return "Unknown"
        end
      else
        "Success: #{state_ovr_data["pa_transaction_id"]}"
      end
    else     
      existing_state_registrant.state_transaction_id.blank? ? ["Error", existing_state_registrant.api_submission_error].join(": ") : "Success: #{existing_state_registrant.state_transaction_id}"
    end
  end
  
  def existing_state_registrant
    return @existing_state_registrant if @existing_state_registrant
    return nil if @existing_state_registrant_fetched
    @existing_state_registrant_fetched = true
    @existing_state_registrant ||= if use_state_flow?  
      state_registrant_type = "StateRegistrants::#{home_state_abbrev}Registrant"
      begin
        model = state_registrant_type.constantize
        model.find_by_registrant_id(self.uid)
      rescue
        nil
      end
    else
      nil
    end
    return @existing_state_registrant    
  end
  
  
  def state_registrant
    if use_state_flow?
      state_registrant_type = "StateRegistrants::#{home_state_abbrev}Registrant"
      begin
        model = state_registrant_type.constantize
        sr = model.from_registrant(self)
      rescue Exception => e
        raise e
        nil
      end
    else
      nil
    end
  end
  
  def has_custom_zip_code_partial?
    File.exists?(File.join(Rails.root, 'app/views/', "registrants/zip_codes/_zip#{home_zip_code}.html.erb"))
  end
  
  def custom_zip_code_partial
    "registrants/zip_codes/zip#{home_zip_code}"
  end

  def custom_step_4_partial
    is_fake? ? "fake_state_online_page" : "#{home_state.abbreviation.downcase}"
  end
  
  def has_home_state_online_registration_instructions?
    File.exists?(File.join(Rails.root, 'app/views/state_online_registrations/', "_#{home_state_online_registration_instructions_partial}.html.erb"))
  end
  
  def home_state_online_registration_instructions_partial
    "#{home_state.abbreviation.downcase}_instructions"
  end

  def has_home_state_online_registration_view?
    File.exists?(File.join(Rails.root, 'app/views/state_online_registrations/', "#{home_state_online_registration_view}.html.erb"))
  end
  
  
  def home_state_online_registration_view
    "#{home_state.abbreviation.downcase}"
  end

  def use_short_form?
    short_form?# && !in_ovr_flow?
  end
    

  def full_name
    [name_title, first_name, middle_name, last_name, name_suffix].compact.join(" ")
  end

  def prev_full_name
    [prev_name_title, prev_first_name, prev_middle_name, prev_last_name, prev_name_suffix].compact.join(" ")
  end

  def phone_and_type
    if phone.blank?
      I18n.t('txt.registration.not_given')
    else
      "#{phone} (#{phone_type})"
    end
  end
  
  # phone_types:
  #   mobile: Mobile
  #   home: Home
  #   work: Work
  #   other: Othe
  def mobile_phone
    if phone_type_key.to_s == "mobile"
      return phone
    else
      ""
    end
  end
  
  def work_phone
    if phone_type_key.to_s == "work"
      return phone
    else
      ""
    end
  end
  
  def home_phone
    if phone_type_key.to_s == "home"
      return phone
    else
      ""
    end
  end

  

  def wrap_up
    complete!
  end

  def complete_registration
    self.status = 'complete'
    saved = self.save!
    queue_pdf
    return saved
  end
  
  def stop_reminders_url
    self.custom_stop_reminders_url.blank? ? default_stop_reminders_url : custom_stop_reminders_url_with_uid
  end
  
  def default_stop_reminders_url
    registrant_finish_url(self, :protocol => "https", :reminders => "stop", :host=>RockyConf.pdf_host_name)
  end
  
  def custom_stop_reminders_url_with_uid
    custom_stop_reminders_url.to_s.gsub("<UID>", self.uid)
  end
  
  
  def to_api_hash
    {
      lang: locale,
      partner_id: remote_partner_id,
      send_confirmation_reminder_emails: send_emails?,
      collect_email_address: collect_email_address,
      source_tracking_id: tracking_source,
      partner_tracking_id: tracking_id,
      short_form: use_short_form?,
      state_ovr_data: state_ovr_data,
      created_at: created_at.to_s(:db),
      updated_at: updated_at.to_s(:db),

      date_of_birth: date_of_birth.blank? ? date_of_birth : date_of_birth.to_s("%m-%d-%Y"),

      id_number: state_id_number,
      email_address: email_address,
      first_registration: first_registration?,
      home_zip_code: home_zip_code,

      us_citizen: us_citizen?,
      has_state_license: has_state_license?,
      is_eighteen_or_older: will_be_18_by_election?,

      name_title: name_title,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      name_suffix: name_suffix,
      home_address: home_address,
      home_unit: home_unit,
      home_city: home_city,
      home_state_id: home_state_abbrev,
      has_mailing_address: has_mailing_address?,
      mailing_address: mailing_address,
      mailing_unit: mailing_unit,
      mailing_city: mailing_city,
      mailing_state_id: mailing_state_abbrev,
      mailing_zip_code: mailing_zip_code,
      race: race,
      party: party,
      phone: phone,
      phone_type: phone_type,
      change_of_name: change_of_name?,
      prev_name_title: prev_name_title,
      prev_first_name: prev_first_name,
      prev_middle_name: prev_middle_name,
      prev_last_name: prev_last_name,
      prev_name_suffix: prev_name_suffix,
      change_of_address: change_of_address?,
      prev_address: prev_address,
      prev_unit: prev_unit,
      prev_city: prev_city,
      prev_state_id: prev_state_abbrev,
      prev_zip_code: prev_zip_code,
      opt_in_email: opt_in_email?,
      opt_in_sms: opt_in_sms?,
      opt_in_volunteer: volunteer?,
      partner_opt_in_email: partner_opt_in_email?,
      partner_opt_in_sms: partner_opt_in_sms?, 
      partner_opt_in_volunteer: partner_volunteer?,
      survey_question_1: survey_question_1,
      survey_answer_1: survey_answer_1, 
      survey_question_2: survey_question_2,
      survey_answer_2: survey_answer_2,
      async: true
    }
  end

  def to_bulk_api_hash
    to_api_hash.merge({
      status: status,
      ineligible_non_participating_state: ineligible_non_participating_state?,
      ineligible_age: ineligible_age?,
      ineligible_non_citizen: ineligible_non_citizen?,
      under_18_ok: under_18_ok?,
      remind_when_18: remind_when_18?,
      age: age,
      javascript_disabled: javascript_disabled?,
      using_state_online_registration: using_state_online_registration?,
      finish_with_state: finish_with_state?
    })
  end

  # Enqueues final registration actions for API calls
  def enqueue_complete_registration_via_api(async=true)
    self.complete_registration_via_api(async)
  end

  # Called from the worker queue to generate PDFs on the 'util' server
  def complete_registration_via_api(async=true)
    if async
      self.status = 'complete'
      saved = self.save
      queue_pdf
      return saved
      
    else 
      self.status = 'complete'
      self.save
      
      generate_pdf
      finalize_pdf
    end
  end
  
  def complete_registration_with_state!
    self.status='complete'
    self.send_confirmation_reminder_emails = false
    self.save(validate: false) # We don't care if it's a valid rocky registrant
  end
  

  def generate_barcode
    self.barcode = self.pdf_barcode
  end

  def partner_absolute_pdf_logo_path
    group = self.is_fake ? :preview : nil
    if partner && (partner.whitelabeled? || group) && partner.pdf_logo_present?(group)
      partner.absolute_pdf_logo_path(group)
    else
      ""
    end
  end

  def generate_pdf!
    generate_pdf(true)
  end
  
  def mail_redacted_pdf
    d = self.pdf_delivery #should have been created in queue_pdf_delivery
    if !d
      d = self.create_pdf_delivery
    end
    # Don't send reminders
    self.reminders_left = 0
    self.save(validate: false)
    return d.generate_pdf!
  end
  
  def queue_pdf
    klass = PdfGeneration
    if self.email_address.blank?
      klass = PriorityPdfGeneration
    end
    klass.create!(:registrant_id=>self.id)
  end
  
  def queue_pdf_delivery
    d = self.pdf_delivery
    if !d
      d = self.create_pdf_delivery
      klass= PdfDeliveryGeneration
      klass.create!(:registrant_id=>self.id)    
    end
  end
  
  def download_pdf
    self.pdf_downloaded = true
    self.pdf_downloaded_at = DateTime.now
    self.save
    return pdf_url
  end
  
  def pdf_file_path(pdfpre=nil)
    pdf_writer.pdf_file_path(pdfpre)
  end
  
  def pdf_url(pdfpre = nil, file=false)
   "http://rocky-pdfs#{Rails.env.production? ? '' : "-#{Rails.env}"}.s3-website-us-west-2.amazonaws.com#{pdf_path(pdfpre, file)}"
  end
  def pdf_path(pdfpre = nil, file=false)
    pdf_writer.pdf_path(pdfpre, file)
  end
  def pdf_download_path
    pdf_registrant_download_path(self)
  end
  
  def pdf_file_dir(pdfpre = nil)
    pdf_writer.pdf_file_dir(pdfpre)
  end
  
  

  def pdf_writer
    if @pdf_writer.nil?
      @pdf_writer = PdfWriter.new
      @pdf_writer.assign_attributes(self.to_pdf_hash)
    end
    @pdf_writer
  end

  def generate_pdf(force = false)
    if pdf_writer.valid?
      if pdf_writer.generate_pdf(force)
        deliver_confirmation_email
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  
  def lang
    locale
  end
  
  def finalize_pdf
    self.status = 'complete' # lets make sure this is set
    self.pdf_ready = true
    redact_sensitive_data
    save
  end
  
  def home_state_enabled_for_pdf_assitance?
    return false
    # list = %w(AL
    #           SD)
    # return list.include?(home_state_abbrev)
  end
  
  def can_request_pdf_assistance?
    self.locale.to_s == 'en' && (Rails.env.production? ? self.partner_id == 37284 : self.partner_id == 1) && home_state_enabled_for_pdf_assitance?
  end
  
  def to_pdf_hash
    {
      :id =>  id,
      :uid  =>  uid,
      :locale => locale,
      :email_address => email_address,
      :us_citizen => us_citizen?,
      :will_be_18_by_election => will_be_18_by_election?,
      :home_zip_code => home_zip_code,
      :name_title_key => name_title_key,        
      :first_name => first_name,         
      :middle_name => middle_name,        
      :last_name => last_name,   
      :name_suffix_key => name_suffix_key,        
      :home_address => home_address,       
      :home_unit => home_unit,        
      :home_city => home_city,
      :home_state_id => home_state_abbrev,  
      :home_state_name => home_state && home_state.name,     
      :state_id_tooltip => state_id_tooltip,
      :has_mailing_address => has_mailing_address?,
      :mailing_address => mailing_address,    
      :mailing_unit => mailing_unit,      
      :mailing_city => mailing_city,       
      :mailing_state_id => mailing_state_abbrev,
      :mailing_zip_code => mailing_zip_code,
      :phone => phone,          
      :state_id_number => state_id_number,
      :prev_name_title_key => prev_name_title_key,    
      :prev_first_name => prev_first_name,    
      :prev_middle_name => prev_middle_name,   
      :prev_last_name => prev_last_name, 
      :prev_name_suffix_key => prev_name_suffix_key,
      :prev_address => prev_address,   
      :prev_unit => prev_unit,       
      :prev_city => prev_city,          
      :prev_state_id => prev_state_abbrev,
      :prev_zip_code => prev_zip_code,
      :partner_absolute_pdf_logo_path => partner_absolute_pdf_logo_path,
      :registration_instructions_url => registration_instructions_url,
      :home_state_pdf_instructions => home_state_pdf_instructions,
      :home_state_pdf_other_instructions => home_state_pdf_other_instructions,
      :state_registrar_address => state_registrar_address,
      :registration_deadline => registration_deadline,
      :party => party,
      :english_party_name => pdf_english_party_name,
      :pdf_english_race => pdf_english_race,
      :pdf_date_of_birth => pdf_date_of_birth,
      :pdf_barcode => pdf_barcode,
      pdf_assistant_info: pdf_assistant_info,
      :created_at => created_at.to_param
    }
  end
  
  def to_finish_with_state_array
    [{:status               => self.extended_status,
    :create_time          => self.created_at.to_s,
    :complete_time        => self.completed_at.to_s,
    :lang                 => self.locale,
    :first_reg            => self.first_registration?,
    :home_zip_code        => self.home_zip_code,
    :us_citizen           => self.us_citizen?,
    :name_title           => self.name_title,
    :first_name           => self.first_name,
    :middle_name          => self.middle_name,
    :last_name            => self.last_name,
    :name_suffix          => self.name_suffix,
    :home_address         => self.home_address,
    :home_unit            => self.home_unit,
    :home_city            => self.home_city,
    :home_state_id        => self.home_state_id,
    :has_mailing_address  => self.has_mailing_address,
    :mailing_address      => self.mailing_address,
    :mailing_unit         => self.mailing_unit,
    :mailing_city         => self.mailing_city,
    :mailing_state_id     => self.mailing_state_id,
    :mailing_zip_code     => self.mailing_zip_code,
    :race                 => self.race,
    :party                => self.party,
    :phone                => self.phone,
    :phone_type           => self.phone_type,
    :email_address        => self.email_address,
    :source_tracking_id   => self.tracking_source,
    :partner_tracking_id  => self.tracking_id}]
  end
  
  def send_emails?
    !email_address.blank? && !is_blacklisted(email_address) && collect_email_address? && (!building_via_api_call? || send_confirmation_reminder_emails?)
  end
  
  def is_blacklisted(email_address)
    EmailAddress.is_blacklisted?(email_address)
  end

  def deliver_confirmation_email
    if send_emails?
      Notifier.confirmation(self).deliver
      enqueue_reminder_emails
    end
  end
  
  def deliver_chaser_email
    if send_emails?
      Notifier.chaser(self).deliver
    end
  end
  
  def deliver_thank_you_for_state_online_registration_email
    if send_emails?
      Notifier.thank_you_external(self).deliver
    end
  end

  def enqueue_reminder_emails
    if send_emails?
      self.reminders_left = REMINDER_EMAILS_TO_SEND
    else
      self.reminders_left = 0
    end
  end

  def deliver_reminder_email
    if reminders_left > 0 && send_emails?
      Notifier.reminder(self).deliver
      self.reminders_left = reminders_left - 1
      self.save(validate: false)
    end
  rescue StandardError => error
    Airbrake.notify(
      :error_class => error.class.name,
      :error_message => "Email Delivery Error(#{error.class.name}) for registrant #{self.id}: #{error.message}\n #{error.backtrace}",
      :request => { :params => {:worker => "deliver_reminder_email", :registrant_id => self.id} })
  end
  
  def deliver_final_reminder_email
    if send_emails? && !final_reminder_delivered && !pdf_downloaded && pdf_ready?
      begin
        Notifier.final_reminder(self).deliver
      rescue
        # If we can't deliver, just stop
      end
      self.final_reminder_delivered = true
      self.save(validate: false)
    elsif !pdf_downloaded && pdf_ready?
      self.final_reminder_delivered = true
      self.save(validate: false)
    end
  end

  def redact_sensitive_data
    self.state_id_number = nil
  end
  
  def bucket_code
    pdf_writer.bucket_code
  end

  def check_ineligible
    self.ineligible_non_participating_state = home_state && !home_state.participating?
    self.ineligible_age = age && age < 18
    self.ineligible_non_citizen = !us_citizen? && (!use_short_form? || at_least_step_2? || rejected?)
    true # don't halt save in after_validation
  end

  def ineligible?
    ineligible_non_participating_state || (ineligible_age && !(under_18_ok || automatic_under_18_ok?)) || ineligible_non_citizen
  end

  def automatic_under_18_ok?
    localization ? localization.automatic_under_18_ok?(self) : false
  end

  def eligible?
    !ineligible?
  end

  def rtv_and_partner_name
    if partner && !partner.primary?
      I18n.t('txt.rtv_and_partner', :partner_name=>partner.organization)
    else
      "Rock the Vote"
    end
  end

  def finish_iframe_url
    base_url = FINISH_IFRAME_URL
    if self.partner && !self.partner.primary? && self.partner.whitelabeled? && !self.partner.finish_iframe_url.blank?
      base_url = self.partner.finish_iframe_url
    end
    url = "#{base_url}?locale=#{self.locale}&email=#{self.email_address}"
    url += "&partner_id=#{self.partner.id}" if !self.partner.nil?
    url += "&source=#{self.tracking_source}" if !self.tracking_source.blank?
    url += "&tracking=#{self.tracking_id}" if !self.tracking_id.blank?
    url
  end

  def email_address_to_send_from
    if partner && !partner.primary? && partner.whitelabeled? && !partner.from_email.blank? && partner.from_email_verified?
      partner.from_email
    else
      RockyConf.from_address
    end
  end

  def survey_question_1
    original_survey_question_1.blank? ? partner_survey_question_1 : original_survey_question_1
  end

  def survey_question_2
    original_survey_question_2.blank? ? partner_survey_question_2 : original_survey_question_2
  end

  def geo_location
    geo = (self.state_ovr_data || {})["geo_location"]
    if geo && geo["lat"] && geo["long"]
      return "lat: #{geo['lat']} lon: #{geo['long']}"
    else
      return nil
    end
  end

  def to_csv_array
    [
      status.humanize,
      self.tracking_source,
      self.tracking_id,
      self.open_tracking_id,
      api_submission_status,
      locale_english_name,
      pdf_date_of_birth,
      email_address,
      yes_no(us_citizen?),
      name_title,
      first_name,
      middle_name,
      last_name,
      name_suffix,
      home_address,
      home_unit,
      home_city,
      home_county,
      home_state && home_state.abbreviation,
      home_zip_code,
      yes_no(has_mailing_address?),
      mailing_address,
      mailing_unit,
      mailing_city,
      mailing_county,
      mailing_state_abbrev,
      mailing_zip_code,
      party,
      race,
      phone,
      phone_type,
      yes_no(opt_in_email?),
      yes_no(opt_in_sms?),
      yes_no(partner_opt_in_email?),
      yes_no(partner_opt_in_sms?),
      survey_question_1,
      survey_answer_1,
      survey_question_2,
      survey_answer_2,
      yes_no(volunteer?),
      yes_no(partner_volunteer?),
      ineligible_reason,
      yes_no(complete? && ineligible_age? && (under_18_ok? || automatic_under_18_ok?)),
      created_at && created_at.in_time_zone("America/New_York").to_s,
      yes_no(finish_with_state?),
      yes_no(building_via_api_call?),
      yes_no(has_state_license?),
      yes_no(has_ssn?),
      
      vr_application_submission_modifications,
      vr_application_submission_errors,
      
      vr_application_status,
      vr_application_status_details,
      vr_application_status_datetime,
      
      yes_no(submitted_via_state_api?),
      api_submitted_with_signature,
      
    ]
  end
  
  def to_grommet_csv_array
    [
      status.humanize,
      self.tracking_source, #Canvasser Name/ID
      self.canvasser_name, #Canvasser Name only
      self.tracking_id, # Event Zip
      self.open_tracking_id, #Event Name
      
      tablet_id, 
      
      api_submission_status,
      locale_english_name,
      pdf_date_of_birth,
      email_address,
      yes_no( will_be_18_by_election?),
     
     
      yes_no(us_citizen?),
      name_title,
      first_name,
      middle_name,
      last_name,
      name_suffix,
      home_address,
      home_unit,
      home_city,
      home_county,
      home_state && home_state.abbreviation,
      home_zip_code,
      yes_no(has_mailing_address?),
      mailing_address,
      mailing_unit,
      mailing_city,
      mailing_county,
      mailing_state_abbrev,
      mailing_zip_code,
     
      grommet_preferred_language, # TODO: Preferred Lanuage selection
     
      party,
      race,
      
      mobile_phone,
      home_phone,
      work_phone,
      
      yes_no(partner_opt_in_email?),
      yes_no(partner_opt_in_sms?),
      yes_no(partner_volunteer?),
      vr_generated_at,
      yes_no(has_state_license?),
      yes_no(has_ssn?),
      
      api_submitted_with_signature,
      geo_location,
      
      vr_application_submission_modifications,
      vr_application_submission_errors,
      vr_application_status,
      vr_application_status_details,
      vr_application_status_datetime,
      self.id     
    ]
  end
  
  def vr_generated_at
    eastern_time(state_ovr_data["voter_records_request"]["generated_date"])
  rescue
    nil
  end
  
  def vr_application_status
    registrant_status ? registrant_status.state_status : nil
  end
  
  def vr_application_status_details
    registrant_status ? registrant_status.state_status_details : nil
  end
  
  def vr_application_status_datetime
    registrant_status && registrant_status.updated_at ? registrant_status.updated_at.in_time_zone("America/New_York").to_s : nil    
  end

  def vr_application_submission_modifications
    ([state_ovr_data["state_api_validation_modifications"]].flatten.compact).join(", ")
  rescue
    ""
  end
  
  def grommet_preferred_language
    r.state_ovr_data["voter_records_request"]["voter_registration"]["additional_info"].detect{|a| a["name"]=="preferred_language"}["string_value"]    
  rescue
    ""
  end
  
  def vr_application_submission_errors
    ([state_ovr_data["errors"]].flatten.compact).collect do |e| 
      e_msg = e.is_a?(Array) ? e.join("\n") : e.to_s
      e_msg =~ /^Backtrace\n/ ? nil : e_msg 
    end.compact.join(", ")
  rescue
    ""
  end
  
  def status_text
    I18n.locale = self.locale.to_sym
    @status_text ||=
      CGI.escape(
        case self.status.to_sym
        when :complete, :step_5 ; I18n.t('txt.status_text.message')
        when :under_18 ; I18n.t('txt.status_text.under_18_message')
        else ""
        end
        )
  end

  ### tell-a-friend email

  attr_writer :tell_from, :tell_email, :tell_recipients, :tell_subject, :tell_message
  attr_accessor :tell_recipients, :tell_message

  def tell_from
    @tell_from ||= "#{first_name} #{last_name}"
  end

  def tell_email
    @tell_email ||= send_emails? ? email_address : email_address_to_send_from
  end

  def tell_subject
    @tell_subject ||=
      case self.status.to_sym
      when :complete ; I18n.t('email.tell_friend.subject')
      when :under_18 ; I18n.t('email.tell_friend_under_18.subject')
      end
  end

  def enqueue_tell_friends_emails
    if @telling_friends && self.errors.blank?
        tell_params = {
          :tell_from       => self.tell_from,
          :tell_email      => self.tell_email,
          :tell_recipients => self.tell_recipients,
          :tell_subject    => self.tell_subject,
          :tell_message    => self.tell_message
        }
      self.class.send_later(:deliver_tell_friends_emails, tell_params)
    end
  end

  def self.deliver_tell_friends_emails(tell_params)
    # disabled until spammers can be stopped
    #tell_params[:tell_recipients].split(",").each do |recipient|
    #  Notifier.deliver_tell_friends(tell_params.merge(:tell_recipients => recipient))
    #end
  end

  def self.backfill_data
    counter = 0
    self.find_each do |r|
      r.calculate_age
      r.set_official_party_name
      r.generate_barcode
      r.save(:validate=>false)
      unless Rails.env.test?
        putc "." if (counter += 1) % 1000 == 0; $stdout.flush
      end
    end
    puts " done!" unless Rails.env.test?
  end

  def completed_at
    complete? && updated_at || nil
  end

  def extended_status
    if complete?
      'complete'
    elsif /step/ =~ status.to_s
      "abandoned after #{status}".gsub('_', ' ')
    else
      'abandoned'
    end
  end

  def has_phone?
    !phone.blank?
  end

  private ###



  def generate_uid
    self.uid = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email_address} -- #{home_zip_code}" )
  end
  
  def set_dl_defaults
    if has_state_license.nil? && self.home_state_allows_ovr_ignoring_license?
      self.has_state_license = true
    end
  end

  
  def method_missing(sym, *args)
    if sym.to_s =~ /\Ayes_no_(.+)\z/
      attribute = $1
      return self.send(:yes_no, (self.send(attribute)))
    else
      super
    end
  end
  
  def ineligible_reason
    case
    when ineligible_non_citizen? then "Not a US citizen"
    when ineligible_non_participating_state? then "State doesn't participate"
    when ineligible_age? then "Not old enough to register"
    else nil
    end
  end

  def partner_survey_question_1
    locale.blank? ? "" : partner.send("survey_question_1_#{locale}")
  end

  def partner_survey_question_2
    locale.blank? ? "" : partner.send("survey_question_2_#{locale}")
  end

  def set_questions
    if self.survey_answer_1_changed? && !self.original_survey_question_1_changed?
      self.original_survey_question_1 = partner_survey_question_1
    end
    if self.survey_answer_2_changed? && !self.original_survey_question_2_changed?
      self.original_survey_question_2 = partner_survey_question_2
    end
    true
  end
  
  def set_will_be_18
    self.will_be_18_by_election = true unless self.require_age_confirmation?
    return true
  end
  
  def set_finish_with_state
    self.finish_with_state = false unless (self.home_state_online_reg_enabled? || self.state_ovr_data[:force_finish_with_state])
    return true
  end
  
  def limit_zip_codes
    [:home_zip_code, :mailing_zip_code, :prev_zip_code].each do |attr_name|
      value = self.send(attr_name)
      if value && value.length > 10
        self.send("#{attr_name}=", value.to_s[0...10])
      end
    end
  end
  
end
