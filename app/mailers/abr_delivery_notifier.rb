class AbrDeliveryNotifier < ActionMailer::Base

  def deliver_to_elections_office(abr)
    attachments["absentee-request.pdf"] = open(abr.pdf_url).read    
    mail = setup_delivery_email(abr, "deliver_to_elections_office")
    begin
      AbrEmailDelivery.create({
        abr_id: abr.id,
        to_email: mail.to.first
      })
    rescue => exception      
    end
    return mail
  end

  def setup_delivery_email(abr, kind)
    partner = abr.partner
    use_custom_template = false #partner.whitelabeled?
    
    # call message_body first to set up instance variables
    body = message_body(abr, kind)
    
    subject = I18n.t("email.abr.#{kind}.subject", :locale => abr.locale.to_sym)
    
    # TODO add separate pixel tracking codes for abr versios of emails?
    pixel_tracking_code =  nil #pixel_tracking(abr, kind)
    
    m = mail(
        :subject=>subject,
        :from=>abr.email_address_to_send_form_delivery_from,
        :to=>abr.elections_office_email,
        cc: abr.email,
        :date=> Time.now.to_s(:db)
    ) do |format|
      format.html { 
        body.to_s + pixel_tracking_code.to_s.html_safe
      }
    end

    m

  end

  def message_body(abr, kind)
    #TODO
    @election_office_name = abr.elections_office_name

    @pdf_url = "http://#{RockyConf.pdf_host_name}#{abr.pdf_download_path}?source=email"
    @cancel_reminders_url = abr.stop_reminders_url.to_s.html_safe
    @locale               = abr.locale.to_sym
    @registrar_phone      = abr.home_state.registrar_phone.to_s.html_safe
    @registrar_address    = abr.state_registrar_address.to_s.html_safe
    @registrar_url        = abr.home_state.registrar_url.to_s.html_safe
    @abr                  = abr
    @abr_first_name = abr.first_name.to_s.html_safe
    @abr_last_name = abr.last_name.to_s.html_safe
    @abr_rtv_and_partner_name = abr.rtv_and_partner_name.to_s.html_safe
    @abr_home_state_name = abr.home_state_name.to_s.html_safe
    @abr_home_state_system_name = abr.home_state_system_name.to_s.html_safe
    @abr_home_state_abbrev = abr.home_state_abbrev.to_s.html_safe
    @rtv_link = "<strong><a href=\"http://register.rockthevote.com/?partner=#{abr.partner_id}&source=email-#{kind}\">register.rockthevote.com</a></strong>".html_safe
    @home_state_email_instructions = abr.home_state_email_instructions.blank? ? '' : (abr.home_state_email_instructions + "<br/><br/>").to_s.html_safe

    partner = abr.partner
    use_custom_template = false #partner.whitelabeled? || kind.starts_with?("preview_")
    
    render "abr_delivery_notifier/#{kind}"    
  end

end