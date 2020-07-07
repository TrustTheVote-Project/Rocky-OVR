class Abr < ActiveRecord::Base
  include RegistrantMethods
  
  belongs_to :home_state,    :class_name => "GeoState"
  belongs_to :mailing_state, :class_name => "GeoState"
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :zip
  validates_presence_of :date_of_birth
  
  before_create :generate_uid
  
  
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
  
  def home_state_abbrev
    home_state && home_state.abbreviation
  end
  
  def zip=(zip)
    self[:zip] = zip
    if zip && !zip.blank?
      self.home_state_id = (s = GeoState.for_zip_code(zip.strip)) ? s.id : self.home_state_id
    end
  end
  
  def to_param
    uid
  end
  
  def generate_uid
    self.uid = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email} -- #{zip}" )
    return self.uid
  end
  
  def mailing_state_abbrev=(abbrev)
    self.mailing_state = GeoState[abbrev]
  end

  def mailing_state_abbrev
    mailing_state && mailing_state.abbreviation
  end
  
  def home_state_name
    home_state && home_state.name
  end
  
  def mailing_state_name
    mailing_state && mailing_state.name
  end
  
  
end
