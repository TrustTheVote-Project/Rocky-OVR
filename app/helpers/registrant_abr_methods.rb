module RegistrantAbrMethods
  def finish_iframe_url
    base_url = self.is_a?(Abr) ? "https://s3.rockthevote.com/rocky/rtv-abr-share.php" : Registrant::FINISH_IFRAME_URL
    if self.partner && !self.partner.primary? && self.partner.whitelabeled? && !self.partner.finish_iframe_url.blank?
      base_url = self.partner.finish_iframe_url
    end
    url = "#{base_url}?locale=#{self.locale}&email=#{self.email_address}"
    url += "&partner_id=#{self.partner.id}" if !self.partner.nil?
    url += "&source=#{self.tracking_source}" if !self.tracking_source.blank?
    url += "&tracking=#{self.tracking_id}" if !self.tracking_id.blank?
    url
  end


  def any_email_opt_ins?
    collect_email_address? && (partner.rtv_email_opt_in || partner.primary? || partner.partner_email_opt_in)
  end
  
  def any_phone_opt_ins?
    partner.rtv_sms_opt_in || partner.partner_sms_opt_in? || partner.primary?
  end
  
  def is_blacklisted(email_address)
    EmailAddress.is_blacklisted?(email_address)
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
  
  def rtv_and_partner_name
    if partner && !partner.primary?
      I18n.t('txt.rtv_and_partner', :partner_name=>partner.organization)
    else
      "Rock the Vote"
    end
  end
  
  def email_address_to_send_from
    if partner && !partner.primary? && partner.whitelabeled? && !partner.from_email.blank? && partner.from_email_verified?
      partner.from_email
    else
      RockyConf.from_address
    end
  end
  
  def enqueue_reminder_emails
    if send_emails?
      self.reminders_left = self.class.reminder_emails_to_send
    else
      self.reminders_left = 0
    end
  end
  
end
