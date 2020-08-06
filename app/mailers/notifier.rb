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
class Notifier < ActionMailer::Base
  
  def partner_terms_of_use(partner)
    @name = partner.name
    @name = "Friend" if @name.blank?
    @tou_url = "https://www.rockthevote.org/programs-and-partner-resources/tech-for-civic-engagement/partner-ovr-tool-faqs/#termsofuse"
    @partner_signup_url = "https://docs.google.com/forms/d/e/1FAIpQLSck6XJO2SQeSIenDpuHgNBUop9ENtvsGhMWLFYQDsy-VgO8pg/viewform"
    @partner_tool_faqs = "https://www.rockthevote.org/programs-and-partner-resources/tech-for-civic-engagement/partner-ovr-tool-faqs/partner-ovr-tool-faqs/"
    mail(subject: "Rock the Vote Terms of Use",
         from: RockyConf.from_address,
         to: partner.email,
         date: Time.now.to_s(:db))
  end
  
  def password_reset_instructions(partner)
    @url = "http://#{RockyConf.default_url_host}#{edit_password_reset_path(:id => partner.perishable_token)}"
    
    
    mail(:subject=> "Password Reset Instructions",
         :from => RockyConf.from_address,
         :to => partner.email,
         :date => Time.now.to_s(:db))
  end
  
  def admin_password_reset_instructions(admin)
    @url = "http://#{RockyConf.default_url_host}#{edit_admin_password_reset_path(:id => admin.perishable_token)}"
    
    
    mail(:subject=> "Password Reset Instructions",
         :from => RockyConf.from_address,
         :to => admin.email,
         :date => Time.now.to_s(:db))
  end
  
  def admin_password_reset_required(admin)
    @url = "http://#{RockyConf.default_url_host}#{new_admin_password_reset_path}"
    
    
    mail(:subject=> "Password Reset Required",
         :from => RockyConf.from_address,
         :to => admin.email,
         :date => Time.now.to_s(:db))
  end
  
  def continue_on_device(registrant, signature_capture_url)
    @registration_url = signature_capture_url
    setup_registrant_email(registrant, 'continue_on_device', registrant.email_address_for_continue_on_device)    
  end
  
  def confirmation(registrant)
    setup_registrant_email(registrant, 'confirmation')
  end

  def thank_you_external(registrant)
    setup_registrant_email(registrant, 'thank_you_external')
  end

  def reminder(registrant)
    setup_registrant_email(registrant, 'reminder')
  end
  
  def final_reminder(registrant)
    setup_registrant_email(registrant, 'final_reminder')
  end
  
  def chaser(registrant)
    setup_registrant_email(registrant, 'chaser')
  end

  def tell_friends(tell_params)
    @message = tell_params[:tell_message]
    mail(:subject => tell_params[:tell_subject],
      :from => "#{tell_params[:tell_from]} <#{tell_params[:tell_email]}>",
      :to => tell_params[:tell_recipients],
      :date => Time.now.to_s(:db))
    
  end

  
  def preview_message(partner, prefix, kind, locale)
    registrant = Registrant.new(first_name: "FirstName", last_name: "LastName", partner: partner, locale: locale, home_state: GeoState[1])
    registrant.id = 0
    registrant.uid = '0000000'
    is_preview_found = !!EmailTemplate.get(partner, "#{prefix}#{kind}.#{locale}")
    template_name = is_preview_found ? (prefix + kind) : kind
    begin
      return setup_registrant_email(registrant, template_name)
    rescue Exception => e
      m = mail(
        :subject=> "Error Parsing Template: #{e.message}",
        :from=>registrant.email_address_to_send_from,
        :to=>registrant.email_address,        
      ) do |format| 
        format.html { 
          e.backtrace.to_s.html_safe 
        }
      end
    end
  end

  protected

  def setup_registrant_email(registrant, kind, to_address = nil)
    if registrant.is_fake? && !kind.starts_with?("preview_")
      kind = "preview_#{kind}"
    end
    partner = registrant.partner
    use_custom_template = partner.whitelabeled? || kind.starts_with?("preview_")
    subject = partner && (use_custom_template) && EmailTemplate.get_subject(partner, "#{kind}.#{registrant.locale}")
    
    
    # call message_body first to set up instance variables
    body = message_body(registrant, kind)
    
    subject = subject.blank? ? I18n.t("email.#{kind}.subject", :locale => registrant.locale.to_sym) : ERB.new(subject).result(binding)
    
    pixel_tracking_code = pixel_tracking(registrant, kind)
    
    m = mail(
        :subject=>subject,
        :from=>registrant.email_address_to_send_from,
        :to=>to_address || registrant.email_address,
        :date=> Time.now.to_s(:db)
      ) do |format|
        format.html { 
          body.to_s + pixel_tracking_code.to_s.html_safe
        }
    end

    m.transport_encoding = "quoted-printable"
    
    m

  end

  def pixel_tracking(registrant, kind)
    partner = registrant.partner
    ptc = partner && partner.whitelabeled? && partner.send("#{kind}_pixel_tracking_code")
    if ptc.blank?
      ptc = partner && partner.default_pixel_tracking_code(kind)
    end
    
    ptc = ERB.new(ptc.to_s.html_safe).result(binding)

    return ptc.to_s.html_safe
  end

  def message_body(registrant, kind)
    @pdf_url = "http://#{RockyConf.pdf_host_name}#{registrant.pdf_download_path}?source=email"
    @cancel_reminders_url = registrant.stop_reminders_url.to_s.html_safe
    @locale               = registrant.locale.to_sym
    @registrar_phone      = registrant.home_state.registrar_phone.to_s.html_safe
    @registrar_address    = registrant.state_registrar_address.to_s.html_safe
    @registrar_url        = registrant.home_state.registrar_url.to_s.html_safe
    @registrant           = registrant
    @registrant_first_name = registrant.first_name.to_s.html_safe
    @registrant_last_name = registrant.last_name.to_s.html_safe
    @registrant_rtv_and_partner_name = registrant.rtv_and_partner_name.to_s.html_safe
    @registrant_home_state_name = registrant.home_state_name.to_s.html_safe
    @registrant_home_state_system_name = registrant.home_state_system_name.to_s.html_safe
    @registrant_home_state_abbrev = registrant.home_state_abbrev.to_s.html_safe
    @rtv_link = "<strong><a href=\"http://register.rockthevote.com/?partner=#{registrant.partner_id}&source=email-#{kind}\">register.rockthevote.com</a></strong>".html_safe
    @home_state_email_instructions = registrant.home_state_email_instructions.blank? ? '' : (registrant.home_state_email_instructions + "<br/><br/>").to_s.html_safe

    partner = registrant.partner
    use_custom_template = partner.whitelabeled? || kind.starts_with?("preview_")
    custom_template = partner && use_custom_template && EmailTemplate.get(partner, "#{kind}.#{registrant.locale}")

    if !custom_template.blank?
      render :inline => custom_template
    else
      render "notifier/#{kind}"
    end
  end

  # Wrapper for the custom template
  class Template
    def initialize(body)
      @body = body
    end

    # Need to keep this method to satisfy internal checks of ActionMailer
    def render(*args)
    end

    def render_template(view, *args)
      view.render :inline => @body
    end
  end

end
