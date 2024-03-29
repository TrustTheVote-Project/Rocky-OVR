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
class FinishesController < RegistrationStep
  CURRENT_STEP = 7
  
  skip_before_action :find_partner

  def show
    find_registrant(:finish)
    set_ab_test
    @registrant_finish_iframe_url = @registrant.finish_iframe_url
    @pdf_ready = false
    if params[:finish_with_state]
      @registrant.state_ovr_data[:force_finish_with_state] = true
      @registrant.finish_with_state = true
      if params[:home_state]
        @registrant.home_state = GeoState[params[:home_state]]
      end
      @registrant.save(validate: false)
    end
    if params[:reminders]
      @registrant.update_attributes(:reminders_left => 0, final_reminder_delivered: true)
      @stop_reminders = true
    end
    if params[:share_only] 
      @share_only = true
    elsif !params[:not_ready] && !params[:reminders]
      @pdf_ready = @registrant.pdf_ready?
    end
    set_up_share_variables
  end

  

end
