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
class Step2Controller < RegistrationStep
  CURRENT_STEP = 2

  def render_show
    if @use_mobile_ui
      render "show_mobile_ui" and return
    else
      render "show" and return
    end
  end
  

  def update
    # get rid of home_state_name
    if params[:registrant]
      params[:registrant].delete(:home_state_name)
    end
    params[:registrant][:using_state_online_registration] = !params[:registrant_state_online_registration].nil?
    
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      if reg[:has_mailing_address] == "0"
        reg[:has_mailing_address] = !"#{reg[:mailing_address]}#{reg[:mailing_unit]}#{reg[:mailing_city]}#{reg[:mailing_zip_code]}".blank?
      end
      reg[:change_of_address] = !"#{reg[:prev_address]}#{reg[:prev_unit]}#{reg[:prev_city]}#{reg[:prev_zip_code]}".blank?
      reg[:change_of_name] = !"#{reg[:prev_first_name]}#{reg[:prev_middle_name]}#{reg[:prev_last_name]}".blank?
      
    end
    super
  end

  protected
  
  def advance_to_next_step
    @registrant.advance_to_step_2
    if @registrant.use_short_form?
      @registrant.advance_to_step_3
      if !@registrant.in_ovr_flow?
        @registrant.advance_to_step_4
        @registrant.advance_to_step_5
      end
    end
  end

  def next_url
    if @registrant.use_short_form?
      if @registrant.in_ovr_flow?
        registrant_step_4_url(@registrant)
      else
        registrant_download_url(@registrant)
      end
    else
      registrant_step_3_url(@registrant)
    end
  end

  def redirect_when_eligible
    if @registrant.use_short_form? && !@registrant.in_ovr_flow? && !@registrant.rejected?
      if @pdf_assistance == "1"
        @registrant.wrap_up(:pdf_assistance)
      else
        @registrant.wrap_up
      end
    end
    super
  end



  def set_up_view_variables
    super
    @registrant.mailing_state ||= @registrant.home_state
    @registrant.prev_state ||= @registrant.home_state
    
    
    @state_id_tooltip = @registrant.state_id_tooltip
    
    @state_parties = @registrant.state_parties
    @race_tooltip = @registrant.race_tooltip
    @party_tooltip = @registrant.party_tooltip
    
    if @registrant.use_short_form?
      @question_1 = @registrant.question_1
      @question_2 = @registrant.question_2
    end
    #rescue
    # Allow this to fail from step 1?
  end
end
