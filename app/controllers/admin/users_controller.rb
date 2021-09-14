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
class Admin::UsersController < Admin::BaseController
  def index
    if params[:email] 
      if user = Partner.find_by_email(params[:email])
        redirect_to edit_admin_user_path(user.id) and return
      else
        flash[:warning] = "User #{params[:email]} not found"
      end
    end
    @users = User.paginate(:page => params[:page], :per_page => 10)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params.require(:user).permit(:name, :email, :phone)
    if @user.save
      flash[:success] = "Successfully updated user profile!"      
      redirect_back_or_default admin_users_path
    else
      render action: :edit
    end
  end

  def impersonate
    @user = User.find(params[:id])
    UserSession.create!(@user)
    UserMfaSession.create(@user)
    redirect_to partners_path(@user)
  end

end