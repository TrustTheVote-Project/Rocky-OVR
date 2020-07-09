class Abr < ActiveRecord::Base
  include RegistrantMethods
  include RegistrantAbrMethods
  
  has_many :abrs_catalist_lookups
  has_many :catalist_lookups, through: :abrs_catalist_lookups
  
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  belongs_to :partner
  
  validates_presence_of :first_name, if: :advancing_to_step_3?
  validates_presence_of :last_name, if: :advancing_to_step_3?
  validates_presence_of :address, if: :advancing_to_step_3?
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
  
  before_create :generate_uid
  
  def set_max_step(step)
    self.max_step = [(self.max_step || "0").to_i, step.to_i].max
  end
  
  def collect_email_address?
    true
  end
  
  def home_state_allows_oabr?
    false
  end
  
  def check_if_registered
    false # TODO implement logic base on partner ID and possibly other params
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
    check_registration
    return last_check.is_match?
  end
  
  def should_check_registration?
    self.votercheck.to_s.strip.downcase == 'yes' && partner_enabled_for_votercheck?
  end
  
  def partner_enabled_for_votercheck?
    self.partner.primary? || partner.enabled_for_catalist_api?
  end
  
  def check_registration
    AbrsCatalistLookup.create_lookup(self)
  end
  
  def last_check
    catalist_lookups.last
  end
  
end
