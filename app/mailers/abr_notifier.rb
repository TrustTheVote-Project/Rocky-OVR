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
class AbrNotifier < Notifier
  
  def continue_on_device(abr, signature_capture_url)
    @signature_url = signature_capture_url
    setup_registrant_email(abr, 'continue_on_device', abr.email_address_for_continue_on_device)    
  end
  

  def confirmation(registrant)
    setup_registrant_email(registrant, 'confirmation')
  end

  def deliver_to_elections_office_confirmation(registrant)
    setup_registrant_email(registrant, 'deliver_to_elections_office_confirmation')
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
  
  def preview_message(partner, prefix, kind, locale)
    registrant = Abr.new(first_name: "FirstName", last_name: "LastName", partner: partner, locale: locale, home_state: GeoState[1])
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

  def setup_registrant_email(abr, kind, to_address = nil)
    partner = abr.partner
    use_custom_template = false #partner.whitelabeled? || kind.starts_with?("preview_")
    subject = partner && (use_custom_template) && EmailTemplate.get_subject(partner, "abr.#{kind}.#{abr.locale}")
    
    
    # call message_body first to set up instance variables
    body = message_body(abr, kind)
    
    subject = subject.blank? ? I18n.t("email.abr.#{kind}.subject", :locale => abr.locale.to_sym) : ERB.new(subject).result(binding)
    
    # TODO add separate pixel tracking codes for abr versios of emails?
    pixel_tracking_code =  nil #pixel_tracking(abr, kind)
    
    m = mail(
        :subject=>subject,
        :from=>abr.email_address_to_send_from,
        :to=> to_address ||abr.email,
        :date=> Time.now.to_s(:db)
      ) do |format|
        format.html { 
          body.to_s + pixel_tracking_code.to_s.html_safe
        }
    end

    m.transport_encoding = "quoted-printable"
    
    m

  end

  def message_body(abr, kind)
    #TODO
    @pdf_url = "http://#{RockyConf.pdf_host_name}#{abr.pdf_download_path}?source=email"
    @cancel_reminders_url = abr.stop_reminders_url.to_s.html_safe
    @locale               = abr.locale.to_sym
    @registrar_phone      = abr.home_state.registrar_phone.to_s.html_safe
    @registrar_address    = abr.state_registrar_address.to_s.html_safe
    @registrar_url        = abr.home_state.registrar_url.to_s.html_safe
    @abr                  = abr
    @elections_office_name = abr.elections_office_name
    @status_check_url     = abr.status_check_url
    @status_check_phone     = abr.status_check_phone
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
    custom_template = partner && use_custom_template && EmailTemplate.get(partner, "#{kind}.#{abr.locale}")

    if !custom_template.blank?
      render :inline => custom_template
    else
      render "abr_notifier/#{kind}"
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
