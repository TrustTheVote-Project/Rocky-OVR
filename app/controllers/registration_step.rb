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
class RegistrationStep < ApplicationController
  CURRENT_STEP = -1
  include ApplicationHelper
  include TwilioHelper

  layout "registration"
  before_filter :find_partner
  before_filter :find_canvassing_shift

  rescue_from Registrant::AbandonedRecord do |exception|
    reg = exception.registrant
    redirect_to registrants_timeout_url(partner_locale_options(reg.partner.id, reg.locale, reg.tracking_source))
  end

  def show
    redirected = find_registrant
    return if redirected == :redirected
    set_ab_test
    set_up_view_variables
    render_show
  end

  def update
    redirected = find_registrant
    return if redirected == :redirected
    @registrant.attributes = params[:registrant]
    @registrant.check_locale_change
    set_ab_test
    if detect_state_flow
      @registrant.save(validate: false)
      state_flow_redirect
    else
      set_up_locale
      set_up_view_variables
      rendered = attempt_to_advance
      return if rendered == :rendered
    end
  end

  def current_step
    self.class::CURRENT_STEP
  end
  hide_action :current_step

  protected

  def set_up_locale
    params[:locale] = nil if !I18n.available_locales.collect(&:to_s).include?(params[:locale].to_s)
    @locale = params[:locale] || (@registrant ? @registrant.locale : nil) || 'en'
    I18n.locale = @locale.to_sym
  end


  def set_up_view_variables
    @use_mobile_ui = determine_mobile_ui(@registrant)
  end

  def set_up_share_variables
    @root_url_escaped = CGI::escape(root_url)
    # @registrant.tell_message ||=
    #   case @registrant.status.to_sym
    #   when :under_18
    #     I18n.t('email.tell_friend_under_18.body', :rtv_url => root_url(:source => "email"))
    #   else
    #     I18n.t('email.tell_friend.body', :rtv_url => root_url(:source => "email"))
    #   end
  end

  def skip_advance?
    params[:skip_advance] == "true"  || params.has_key?(:email_continue_on_device) || params.has_key?(:sms_continue_on_device)
  end

  def continue_on_device_advance
    # Set flash message?
    # Actually send the message
    if params.has_key?(:email_continue_on_device) 
      if @registrant.email_address_for_continue_on_device =~ Authlogic::Regex::EMAIL
        Notifier.continue_on_device(@registrant, request.original_url).deliver_now
        flash[:success] = I18n.t('txt.signature_capture.email_sent', email: @registrant.email_address_for_continue_on_device)
        @registrant.save(validate: false) # Make sure data persists even if not valid
      else
        @registrant.errors.add(:email_address_for_continue_on_device, :format)
      end
    elsif params.has_key?(:sms_continue_on_device)
      if @registrant.sms_number =~ /\A\d{10}\z/ #sms number has all non-digits removed
        begin
          twilio_client.messages.create(
            :from => "+1#{twilio_phone_number}",
            :to => @registrant.sms_number,
            :body => I18n.t('txt.signature_capture.sms_body', signature_capture_url: request.original_url)
          )
          flash[:success] = I18n.t('txt.signature_capture.sms_sent', phone: @registrant.sms_number_for_continue_on_device)
          @registrant.save(validate: false) # Make sure data persists even if not valid
          
        rescue Twilio::REST::RequestError
          @registrant.errors.add(:sms_number_for_continue_on_device, :format)
        end
      else
        #controller.flash[:warning] = I18n.t('states.custom.pa.signature_capture.sms_sent', phone: self.sms_number)
        @registrant.errors.add(:sms_number_for_continue_on_device, :format)
      end
    end    
  end

  def attempt_to_advance
    if skip_advance?
      continue_on_device_advance
      render_show
      return :rendered
    end
    advance_to_next_step

    if @registrant.valid?
      @registrant.save_or_reject!

      if @registrant.eligible?
        redirect_when_eligible and return
      else
        redirect_to(registrant_ineligible_url(@registrant)) and return
      end
    else
      set_show_skip_state_fields
      render_show and return :rendererd
    end
  end

  def render_show
    render "show"
  end

  def set_show_skip_state_fields
    @show_fields = "1"
  end

  def redirect_when_eligible
    redirect_to next_url
  end

  def find_registrant(special_case = nil, p = params)
    @registrant = Registrant.find_by_param!(p[:registrant_id] || p[:id])
    if detect_state_flow && special_case.nil?
      state_flow_redirect
      return :redirected
    else
      if (@registrant.complete? || @registrant.under_18?) && special_case.nil?
        raise ActiveRecord::RecordNotFound
      end
      I18n.locale = @registrant.locale

      if @registrant.partner
        @partner    = @registrant.partner
        @partner_id = @partner.id
      end
      if @registrant.finish_with_state? && special_case != :tell_friend && special_case != :finish
        @registrant.update_attributes(:finish_with_state=>false)
      end

    end

  end

  def find_partner
    @partner = Partner.find_by_id(params[:partner]) || Partner.find(Partner::DEFAULT_ID)
    @partner_id = @partner.id
    set_params
  end

  def set_ab_test
    # if @registrant && t = @registrant.ab_tests.where(name: AbTest::MOBILE_UI).first
    #   @mobile_ui_test = t
    # else
    #   @mobile_ui_test = AbTest.assign_mobile_ui_test(@registrant, self)
    # end
  end


  def detect_state_flow

    if @registrant && @registrant.use_state_flow? && !@registrant.skip_state_flow? && current_step != 1
      # PASS registrant over to state flow, creating a new state-specific registrant
      return true
    end
    false
  end

  def state_flow_redirect
    redirect_to edit_state_registrant_path(@registrant.to_param, 'step_2')
  end

  def set_params
    @source = params[:source]
    @tracking = params[:tracking]
    @short_form = (params[:short_form]!="false" && (!@partner || !@partner.use_long_form?)) || MobileConfig.is_mobile_request?(request)
    @collect_email_address = params[:collectemailaddress]
    @email_address = params[:email_address]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @state_abbrev = params[:state_abbrev] || params[:state]
    if @state_abbrev
      @short_form = true
    end
    @home_zip_code = params[:home_zip_code]
    @home_state = @state_abbrev.blank? ? nil : GeoState[@state_abbrev.to_s.upcase]
    @home_state ||= @home_zip_code ? GeoState.for_zip_code(@home_zip_code.strip) : nil

    @shift_id = params[:shift_id]
    @canvassing_shift ||= nil
    if !@shift_id.blank?
      canvassing_shift = CanvassingShift.find_by_shift_external_id(@shift_id)
      if canvassing_shift
        @partner_id = canvassing_shift.partner_id || @partner_id
        @partner= Partner.find_by_id(@partner_id) || @partner
      end
    end


    if !@state_abbrev.blank?
      @short_form = true
    end
  end

  def determine_mobile_ui(registrant)
    return false if registrant.nil?
    #return nil if registrant.javascript_disabled?
    #return nil if registrant.home_state_allows_ovr_ignoring_license?
    #return nil if registrant.locale != 'en'
    #return nil if registrant.partner != Partner.primary_partner #&& registrant.home_state_allows_ovr_ignoring_license?
    return false if registrant && registrant.partner && registrant.partner.whitelabeled? && registrant.partner.any_css_present? && !registrant.partner.partner2_mobile_css_present?
    return false if registrant && !registrant.use_short_form?
    is_mobile = false
    agent = self.request.user_agent.to_s.downcase
    RockyConf.mobile_browsers.each do |b|
      if agent =~ /#{b}/
        is_mobile = true
      end
    end
    return nil if !is_mobile
    return true
  end

  # def redirect_app_role
  #   if ENV['ROCKY_ROLE'] == 'web'
  #     redirect_to "//#{RockyConf.ui_url_host}"
  #   end
  # end
end
