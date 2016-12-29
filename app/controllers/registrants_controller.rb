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
class RegistrantsController < RegistrationStep
  CURRENT_STEP = 1

  # GET /widget_loader.js
  def widget_loader
    @host = host_url
  end

  # GET /registrants
  def landing
    find_partner
    options = {}
    options[:partner] = @partner.to_param if params[:partner]
    options[:locale] = params[:locale] if params[:locale]
    options[:source] = params[:source] if params[:source]
    options[:tracking] = params[:tracking] if params[:tracking]
    options[:short_form] = params[:short_form] if params[:short_form]
    options[:collectemailaddress] = params[:collectemailaddress] if params[:collectemailaddress]
    options[:home_zip_code] = params[:home_zip_code] if params[:home_zip_code]
    options[:state_abbrev] = params[:state_abbrev] if params[:state_abbrev]
    options[:state] = params[:state] if params[:state]
    options[:first_name] = params[:first_name] if params[:first_name]
    options[:last_name] = params[:last_name] if params[:last_name]
    options[:email_address] = params[:email_address] if params[:email_address]
    options.merge!(:protocol => "https") if RockyConf.use_https
    redirect_to new_registrant_url(options)
  end
  
  def share
    @registrant_finish_iframe_url=params[:registrant_finish_iframe_url]
  end

  # GET /registrants/new
  def new
    set_up_locale
    # if MobileConfig.is_mobile_request?(request) && (!@partner || !@partner.mobile_redirect_disabled)
    #   redirect_to MobileConfig.redirect_url(:partner=>@partner_id, :locale=>@locale, :source=>@source, :tracking=>@tracking, :collectemailaddress=>@collect_email_address)
    # else
    if (@home_state && !@home_state.participating?) || (@short_form && (@email_address || @collect_email_address=='no') && @home_state)
      
      # In case it's just a home state being passed, allow to create the registrant anyway
      @short_form = true
      
      params[:registrant] = {
        email_address: @email_address,
        first_name: @first_name,
        last_name: @last_name,
        home_state: @home_state,
        home_zip_code: @home_zip_code,
        is_fake: params.keys.include?('preview_custom_assets')
      }
      create
    else        
      @registrant = Registrant.new(
          partner_id: @partner_id, 
          locale: @locale, 
          tracking_source: @source, 
          tracking_id: @tracking, 
          short_form: @short_form, 
          collect_email_address: @collect_email_address,
          email_address: @email_address,
          first_name: @first_name,
          last_name: @last_name,
          home_state: @home_state,
          home_zip_code: @home_zip_code,
          is_fake: params.keys.include?('preview_custom_assets')
      )
      render "show"
    end
  end

  # POST /registrants
  def create
    set_up_locale
    @registrant = Registrant.new(params[:registrant].reverse_merge(
                                    :locale => @locale,
                                    :partner_id => @partner_id,
                                    :tracking_source => @source,
                                    :tracking_id => @tracking,
                                    :short_form => @short_form,
                                    :collect_email_address => @collect_email_address))
                                    
    if @registrant.partner.primary?
      @registrant.opt_in_email = true
      @registrant.opt_in_sms = true
    else
      if @registrant.partner.rtv_email_opt_in
        @registrant.opt_in_email = true
      end
      if @registrant.partner.rtv_sms_opt_in
        @registrant.opt_in_sms = true
      end 
      if @registrant.partner.partner_email_opt_in
        @registrant.partner_opt_in_email = true
      end
      if @registrant.partner.partner_sms_opt_in
        @registrant.partner_opt_in_sms = true
      end
    end
    attempt_to_advance
  end

  protected


  def advance_to_next_step
    @registrant.advance_to_step_1
  end

  def next_url
    registrant_step_2_url(@registrant)
  end

  def host_url
    "#{request.protocol}#{request.host_with_port}"
  end

end
