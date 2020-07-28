class Abr < ActiveRecord::Base
  include RegistrantMethods
  include RegistrantAbrMethods
  include AbrPdfMethods
  include AbrPdfFields
  
  include AbrStateMethods
  after_initialize :add_state_attributes
  
  has_many :abrs_catalist_lookups
  has_many :catalist_lookups, through: :abrs_catalist_lookups
  
  has_many :abr_state_values, autosave: true
  
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :partner
  
  validates_presence_of :first_name, if: :advancing_to_step_3?
  validates_presence_of :last_name, if: :advancing_to_step_3?
  validates_presence_of :street_number, if: :advancing_to_step_3?
  validates_presence_of :street_name, if: :advancing_to_step_3?
  validates_presence_of :city, if: :advancing_to_step_3?
  validates_presence_of :date_of_birth, if: :advancing_to_step_3?
  validates_presence_of :zip

  def advancing_to_step?(num)
    (current_step || "0").to_i >= num
  end

  def advancing_to_step_2?
    advancing_to_step?(2)
  end

  def advancing_to_step_3?
    advancing_to_step?(3)
  end
  
  def redact_sensitive_data
    # TODO: This will be state-specific!!
    #self.state_id_number = nil
  end
  
  
  before_create :generate_uid
  
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
    home_state && home_state.oabr_url
  end
  
  def oabr_for_all?
    !has_pdf_template?
  end
  
  def locale
    'en'
  end
  
  
  
  def use_state_flow?
    #TBD
    false
  end
  
  def use_short_form?
    true
  end
  
  def require_email_address?
    true
  end
  
  def complete?
    (current_step || "0").to_i >= 4
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
  
  def deliver_confirmation_email
    # TODO implement emails for ABR
  end
  
  
  
  def zip=(zip)
    self[:zip] = zip
    if zip && !zip.blank?
      self.home_state_id = (s = GeoState.for_zip_code(zip.strip)) ? s.id : self.home_state_id
    end
  end
  
  def generate_uid
    self.uid = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email} -- #{zip}" )
    return self.uid
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
      # TODO tracking params
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
  
end
