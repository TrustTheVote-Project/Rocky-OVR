class Abr < ActiveRecord::Base
  belongs_to :home_state,    :class_name => "GeoState"
  
  include RegistrantMethods
  
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
  
  
end
