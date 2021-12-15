class Abr < ActiveRecord::Base
  
  class AbandonedRecord < StandardError
    attr_reader :abr
    def initialize(abr)
      @abr = abr
    end    
  end
  
  include RegistrantMethods
  include RegistrantAbrMethods
  include AbrPdfMethods
  include AbrPdfFields
  include AbrPdfCoverFields
  include AbrSignatureMethods
  include AbrReportingMethods
  include UidGenerator

  has_one :voter_signature, autosave: true
  AbrSignatureMethods::METHODS.each do |vs_attribute|
    define_method "#{vs_attribute}" do
      (voter_signature || build_voter_signature).send(vs_attribute)
    end
    define_method "#{vs_attribute}=" do |val|
      (voter_signature || build_voter_signature).send("#{vs_attribute}=", val)
    end
  end

  
  include AbrStateMethods
  include Rails.application.routes.url_helpers
  
  REMINDER_EMAILS_TO_SEND = 2
  def self.reminder_emails_to_send
    REMINDER_EMAILS_TO_SEND
  end
  
  
  after_initialize :add_state_attributes, unless: ENV['GENERATING_REPORTS']=="true"
  
  has_many :abrs_catalist_lookups
  has_many :catalist_lookups, through: :abrs_catalist_lookups
  
  has_many :abr_state_values, autosave: true
  
  has_many :tracking_events, foreign_key: :source_tracking_id, primary_key: :uid

  belongs_to :home_state,    :class_name => "GeoState", optional: true
  belongs_to :partner, optional: true
  
  before_validation :reformat_phone
  
  validates_presence_of :first_name, if: :advancing_to_step_3?
  validates_presence_of :last_name, if: :advancing_to_step_3?
  validates_presence_of :street_number, if: :advancing_to_step_3?
  validates_presence_of :street_name, if: :advancing_to_step_3?
  validates_presence_of :city, if: :advancing_to_step_3?
  validates_presence_of :date_of_birth, if: :advancing_to_step_3?
  validate :will_be_18, if: :advancing_to_step_3?
  validates_presence_of :zip
  validate :validate_form_fields, if: :advancing_to_step_4?
  validate :validate_date_of_birth, if: :advancing_to_step_3?

  validates_format_of :phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, :allow_blank => true
  validates_presence_of :email
  validates_format_of   :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
  validates_presence_of :phone_type, if: :has_phone?
  validates_presence_of :registration_county, if: :requires_county?
  validate :validates_zip
  validate :validates_signature
  
  def render_view_events
    tracking_events.where(tracking_event_name: "abr::render_view")
  end

  def requires_county?
    advancing_to_step_3? && home_state&.counties&.any?
  end

  def self.validate_fields(list, regex, message)
    list.each do |field|
      validates field, format: { with: regex , 
        message: message }#I18n.t('activerecord.errors.messages.invalid_for_pdf')}
    end    
  end

  def registration_county_name
    home_state.counties[registration_county][:name]
  rescue
    registration_county
  end
  
  MAX_DATE_OF_BIRTH = Date.parse("2002-11-03")
  
  def will_be_18
    if date_of_birth && date_of_birth > MAX_DATE_OF_BIRTH 
      errors.add(:date_of_birth, :too_young)
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
  
  
  ADDRESS_FIELDS = ["street_number", 
    "street_name"]

  CITY_FIELDS = ["city"]

  NAME_FIELDS = ["first_name", 
   "middle_name", 
   "last_name"]

  PDF_FIELDS = [
    "zip",
    "first_name", 
    "middle_name", 
    "last_name", 
    "street_number", 
    "street_name",
    "unit",    
    "city", 
  ]
  
  validate_fields(PDF_FIELDS, Registrant::OVR_REGEX, :invalid_for_pdf)
  validate_fields(NAME_FIELDS, Registrant::OVR_REGEX, :invalid)
  validate_fields(ADDRESS_FIELDS, Registrant::CA_ADDRESS_REGEX, "Valid characters are: A-Z a-z 0-9 # dash space comma forward-slash period")

  def advancing_to_step?(num)
    (current_step || "0").to_i >= num
  end

  def advancing_to_step_2?
    advancing_to_step?(2)
  end

  def advancing_to_step_3?
    advancing_to_step?(3)
  end

  def advancing_to_step_4?
    advancing_to_step?(4)
  end
  
  def set_max_step(step)
    self.max_step = [(self.max_step || "0").to_i, step.to_i].max
  end
  
  def collect_email_address?
    true
  end
  
  def eligible_for_oabr?
    home_state_allows_oabr?
  end
  
  def home_state_allows_oabr?
    home_state && home_state.online_abr_enabled?(self)
  end
  
  def home_state_oabr_url
    home_state && home_state.oabr_url(self)
  end
  
  def oabr_url_is_local_jurisdiction?
    home_state && home_state.oabr_url_is_local_jurisdiction?(self)
  end
  
  def oabr_for_all?
    !has_pdf_template? && !has_state_pdf_url?
  end
  
  def locale
    'en'
  end
  
  def email_address
    email
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
  
  def abandon!
    self.abandoned = true
    self.redact_sensitive_data
    self.save(:validate=>false)
  rescue    
  end
  
  def dead_end!
    self.dead_end = true
    self.redact_sensitive_data #there shouldn't be any
    self.save(validate: false)
  end
  
  COMPLETION_STEP = 4
  def complete?
    (current_step || "0").to_i >= COMPLETION_STEP
  end
  
  def complete_registration
    self.current_step = 4
    saved = self.save!
    queue_pdf
    return saved
  end
  
  def download_pdf
    self.pdf_downloaded = true
    self.pdf_downloaded_at = DateTime.now
    self.save
    return pdf_url
  end
  
  def stop_reminders_url
    finish_abr_url(self, :protocol => "https", :reminders => "stop", :host=>RockyConf.default_url_host)
  end
  
  def send_emails?
    !email.blank? && !is_blacklisted(email)
  end
  
  def deliver_confirmation_email
    if send_emails?
      AbrNotifier.confirmation(self).deliver_now
      enqueue_reminder_emails
    end
  end

  def deliver_to_elections_office
    AbrDeliveryNotifier.deliver_to_elections_office(self).deliver_now
    if send_emails?
      AbrNotifier.deliver_to_elections_office_confirmation(self).deliver_now
    end
  end
  
  def deliver_chaser_email
    if send_emails?
      rendered_step2 = begin
        self.render_view_events.collect {|te| te.tracking_data[:rendered_step] }.include?("abrs-step_2")
      rescue
        false
      end
      
      if rendered_step2 && ChaserDelivery.can_send_chaser?(self.email)
        ChaserDelivery.create({
          email: self.email,
          abr: self
        })
        AbrNotifier.chaser(self).deliver_now
      end
    end
  end
  
  def deliver_thank_you_for_state_online_registration_email
    if send_emails?
      AbrNotifier.thank_you_external(self).deliver_now
    end
  end

  
  def deliver_reminder_email
    if reminders_left > 0 && send_emails?
      AbrNotifier.reminder(self).deliver_now
      self.reminders_left = reminders_left - 1
      self.save(validate: false)
    end
  rescue StandardError => error
  end

  def deliver_final_reminder_email
    if send_emails? && !final_reminder_delivered && !pdf_downloaded && pdf_ready?
      begin
        AbrNotifier.final_reminder(self).deliver_now
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
  
  def state_registrar_office
    @state_registrar_office ||= home_state && home_state.abr_office(self.zip)
  end
  def state_registrar_address
    @state_registrar_address ||= home_state && home_state.abr_address(self.zip)
  end
  
  def county_from_zip
    z = ZipCodeCountyAddress.find_by_zip(self.zip)
    if z
      return z.county[0].to_s
    else
      return ''
    end
  end
  
  def cities_from_zip
    z = ZipCodeCountyAddress.find_by_zip(self.zip)
    if z
      return z.cities
    else
      return []
    end
  end
  
  def home_state_email_instructions
    I18n.t("states.custom.#{i18n_key}.abr.email_instructions", default: '')
  end
  
  def zip=(zip)
    self[:zip] = zip
    if zip && !zip.blank?
      self.home_state_id = (s = GeoState.for_zip_code(zip.strip)) ? s.id : self.home_state_id
    end
  end
  
  def can_continue?
    if !should_check_registration?
      return true
    end
    check_registration_if_updated
    return last_check.is_match?
  end
  
  def should_check_registration?
    self.votercheck.to_s.strip.downcase == 'yes' && partner_enabled_for_votercheck?
  end
  
  def partner_enabled_for_votercheck?
    self.partner.primary? || partner.enabled_for_catalist_api?
  end
  
  def check_registration_if_updated
    lc = self.last_check
    return check_registration unless lc
    new_params = AbrsCatalistLookup.abr_to_catalist_lookup_params(self)
    new_params.each do |k,v|
      return check_registration unless lc.send(k) == v
    end
    return lc
  end
  
  def check_registration
    AbrsCatalistLookup.create_lookup(self)
  end
  
  def last_check
    catalist_lookups.last
  end
  
  def to_registrant
    registrant = Registrant.new({
      partner_id: partner_id,
      tracking_source: tracking_source,
      tracking_id: tracking_id,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      name_suffix: name_suffix,
      home_address: address,
      home_city: city,
      home_zip_code: zip,
      home_state_id: home_state_id,
      email_address: email,
      date_of_birth: date_of_birth
    })
    registrant.locale = locale
    registrant.short_form = true
    registrant.status = :step_1
    registrant
  end
  
  def self.find_by_param(param)
    abr = find_by_uid(param)
    raise AbandonedRecord.new(abr) if abr && abr.abandoned?
    abr
  end

  def self.find_by_param!(param)
    find_by_param(param) || begin raise ActiveRecord::RecordNotFound end
  end
  
  
  def self.abandon_stale_records
    id_list = []
    distribute_reads do 
      id_list = Abr.where("(abandoned != ?) AND (dead_end != ?) AND (current_step < ? OR current_step IS NULL) AND (updated_at < ?)", true, true, Abr::COMPLETION_STEP, RockyConf.minutes_before_abandoned.minutes.seconds.ago).pluck(:id) 

      self.where(["id in (?)", id_list]).find_each(:batch_size=>500) do |abr|
        if abr.finish_with_state?
          abr.current_step = COMPLETION_STEP
          begin
            abr.deliver_thank_you_for_state_online_registration_email
          rescue Exception => e
            Rails.logger.error(e)
            # raise e
          end
          abr.save(validate: false) # Don't want to run into errors that prevent status from being updated and create multiple emails
        else
          # Send chase email
          begin
            abr.deliver_chaser_email
          rescue Exception => e
            Rails.logger.error(e)
          end
        end
        unless abr.complete?
          abr.abandon! 
          Rails.logger.info "ABR #{abr.id} abandoned at #{Time.now}"
        end
      end
    end
  end
  
end
