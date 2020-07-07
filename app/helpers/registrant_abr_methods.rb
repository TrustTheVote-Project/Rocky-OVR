module RegistrantAbrMethods
  def any_email_opt_ins?
    collect_email_address? && (partner.rtv_email_opt_in || partner.primary? || partner.partner_email_opt_in)
  end
  
  def any_phone_opt_ins?
    partner.rtv_sms_opt_in || partner.partner_sms_opt_in? || partner.primary?
  end
  



  def home_state_abbrev
    home_state && home_state.abbreviation
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
  
  
  def to_param
    uid
  end
  
  
  def home_state_online_reg_url
    home_state && home_state.online_reg_url(self)
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
  
  
end
