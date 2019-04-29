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

  layout "registration"
  before_filter :find_partner

  rescue_from Registrant::AbandonedRecord do |exception|
    reg = exception.registrant
    redirect_to registrants_timeout_url(partner_locale_options(reg.partner.id, reg.locale, reg.tracking_source))
  end

  def show
    find_registrant
    set_up_view_variables
  end

  def update
    find_registrant    
    @registrant.attributes = params[:registrant]
    @registrant.check_locale_change
    if detect_state_flow
      @registrant.save(validate: false)
      state_flow_redirect
    else
      set_up_locale
      set_up_view_variables
      attempt_to_advance
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
  

  def attempt_to_advance
    if params[:skip_advance] == "true"
      render 'show' and return
    end
    
    advance_to_next_step

    if @registrant.valid?
      @registrant.save_or_reject!
      
      if @registrant.eligible?
        redirect_when_eligible
      else
        redirect_to registrant_ineligible_url(@registrant)
      end
    else
      set_show_skip_state_fields
      render "show"
    end
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
    
    if !@state_abbrev.blank?
      @short_form = true
    end
  end
  
  # def redirect_app_role
  #   if ENV['ROCKY_ROLE'] == 'web'
  #     redirect_to "//#{RockyConf.ui_url_host}"
  #   end
  # end
end
