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
class PasswordResetsController < PartnerBase
  before_action :load_user_using_perishable_token, :only => [:edit, :update]

  def new
  end

  def edit
  end

  def create
    if user = User.find_by_email(params.permit![:email])
      user.deliver_password_reset_instructions!
      flash[:message] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to login_url
    else
      flash[:warning] = "No account was found with that username or email address"
      render "new"
    end
  end

  def update
    pw = params[:user] && params[:user][:password]
    if pw.blank?
      @user.errors.add(:password, "Password cannot be blank")
      render "edit"
    elsif @user.update_attributes(params[:user].permit!.to_h.try(:slice, :password, :password_confirmation))
      flash[:success] = "Password successfully updated. Please log in using new password."
      redirect_to login_url
    else
      render "edit"
    end
  end

  protected

  def load_user_using_perishable_token
    unless @user = User.find_using_perishable_token(params[:id])
      flash[:warning] = "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."
      redirect_to login_url
    end
  end
end
