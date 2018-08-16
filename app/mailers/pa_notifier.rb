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
class PANotifier < ActionMailer::Base
  def pa_confirmation(registrant)
    setup_registrant_email(registrant, 'pa_confirmation')
  end
  
  def continue_on_device(registrant, signature_capture_url)
    @registration_url = signature_capture_url
    setup_registrant_email(registrant, 'pa_continue_on_device')    
  end


  protected

  def setup_registrant_email(registrant, kind)
    if registrant.is_fake? && !kind.starts_with?("preview_")
      kind = "preview_#{kind}"
    end
    partner = registrant.partner
    # TODO do we allow custom partner content
    use_custom_template = false #partner.whitelabeled? || kind.starts_with?("preview_")
    subject = partner && (use_custom_template) && EmailTemplate.get_subject(partner, "#{kind}.#{registrant.locale}")
    
    
    # call message_body first to set up instance variables
    body = message_body(registrant, kind)
    
    subject = subject.blank? ? I18n.t("email.#{kind}.subject", :locale => registrant.locale.to_sym) : ERB.new(subject).result(binding)
    
    pixel_tracking_code = pixel_tracking(registrant, kind)
    
    m = mail(
        :subject=>subject,
        :from=>registrant.email_address_to_send_from,
        :to=>registrant.email,
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
    @locale               = registrant.locale.to_sym
    @registrar_phone      = registrant.home_state.registrar_phone.to_s.html_safe
    @registrar_address    = registrant.state_registrar_address.to_s.html_safe
    @registrar_url        = registrant.home_state.registrar_url.to_s.html_safe
    @registrant           = registrant
    @registrant_first_name = registrant.first_name.to_s.html_safe
    @registrant_last_name = registrant.last_name.to_s.html_safe
    @registrant_rtv_and_partner_name = registrant.rtv_and_partner_name.to_s.html_safe
    @registrant_home_state_name = registrant.home_state_name.to_s.html_safe
    @registrant_home_state_abbrev = registrant.home_state_abbrev.to_s.html_safe
    @rtv_link = "<strong><a href=\"http://register.rockthevote.com/?partner=#{registrant.partner_id}&source=email-#{kind}\">register.rockthevote.com</a></strong>".html_safe
    @home_state_email_instructions = registrant.home_state_email_instructions.blank? ? '' : (registrant.home_state_email_instructions + "<br/><br/>").to_s.html_safe

    partner = registrant.partner
    use_custom_template = false # partner.whitelabeled? || kind.starts_with?("preview_")
    custom_template = partner && use_custom_template && EmailTemplate.get(partner, "#{kind}.#{registrant.locale}")

    if !custom_template.blank?
      render :inline => custom_template
    else
      render "state_registrant_notifier/#{kind}"
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
