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
class UserSessionsController < PartnerBase
  skip_before_action :require_user
  skip_before_action :require_partner
  skip_before_action :check_mfa

  def new
    if current_user
      redirect_to partners_path
    else
      @user_session = UserSession.new
    end
  end

  def create
    @user_session = UserSession.new(params[:user_session].permit!.to_h)
    if @user_session.save
      redirect_back_or_default partners_path
    else
      # See if this login is a an existing partner
      login = params[:user_session][:email]
      partner = Partner.find_by_login(login)
      if partner && partner.users.count == 0
        User.create_default_partner_user(partner)
      end
      current_user_session&.destroy
      render action: :new
    end
  end

  def destroy
    UserMfaSession::destroy
    current_user_session.destroy
    flash[:success] = "Logged out"
    redirect_back_or_default login_url
  end
end
