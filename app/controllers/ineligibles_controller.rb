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
class IneligiblesController < RegistrationStep
  CURRENT_STEP = 1

  def show
    redirected = find_registrant
    return if redirected == :redirected
    set_ab_test
    set_up_view_variables
    if @registrant.ineligible_age? &&
        !(@registrant.ineligible_non_participating_state? || @registrant.ineligible_non_citizen?)
      @registrant.remind_when_18 = true
      render "under_18"
    else
      render_show
    end
  end

  def update
    find_registrant
    @registrant.update_attributes(registrant_params)
    @registrant.request_reminder!
    redirect_to registrant_finish_url(@registrant)
  end
end
