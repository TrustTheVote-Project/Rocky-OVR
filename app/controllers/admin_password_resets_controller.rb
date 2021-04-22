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
class AdminPasswordResetsController < PartnerBase
  before_action :load_admin_using_perishable_token, :only => [:edit, :update]

  def new
  end

  def edit
  end

  def create
    if @admin = Admin.find_by_email(params[:login])
      @admin.deliver_password_reset_instructions!
      flash[:message] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to admin_login_url
    else
      flash[:warning] = "No account was found with that username or email address"
      render "new"
    end
  end

  def update
    pw = params[:admin] && params[:admin][:password]
    if pw.blank?
      @admin.errors.add(:password, "Password cannot be blank")
      render "edit"
    else
      @admin.password = params[:admin][:password]
      @admin.password_confirmation = params[:admin][:password_confirmation]
      if @admin.save_without_session_maintenance
        flash[:success] = "Password successfully updated. Please log in using new password."
        redirect_to admin_login_url
      else
        render "edit"
      end
    end
  end

  protected

  def load_admin_using_perishable_token
    unless @admin = Admin.find_using_perishable_token(params[:id])
      flash[:warning] = "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."
      redirect_to admin_login_url
    end
  end
end
