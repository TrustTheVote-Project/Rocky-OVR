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
class PartnerBase < ApplicationController
  layout "partners"
  
  helper_method :current_user, :current_admin, :current_admin_session
  before_action :require_user
  before_action :require_partner
  before_action :check_mfa
  before_action :init_nav_class


  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  protected
  
  def check_mfa
    if !(user_mfa_session = UserMfaSession.find) && (user_mfa_session ? user_mfa_session.record == current_user : !user_mfa_session)
      store_location
      redirect_to new_mfa_session_path
    end
  end

  def current_admin_session
    return @current_admin_session if defined?(@current_admin_session)
    @current_admin_session = AdminSession.find
  end

  def current_admin
    return @current_admin if defined?(@current_admin)
    @current_admin = current_admin_session && current_admin_session.record
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def require_partner
    @partner = Partner.find( params[:partner_id] || params[:id])
    if current_admin || current_user.partners.include?(@partner)
      return true
    else
      flash[:warning] = "You do not have access to this partner"
      redirect_to partners_path
      return false
    end
  end

  def require_user
    unless current_user || current_admin
      store_location
      force_logout
      flash[:warning] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
    return true
  end

  def force_logout
    UserMfaSession::destroy    
    current_user_session.destroy if current_user
    remove_instance_variable :@current_user_session if defined?(@current_user_session)
    remove_instance_variable :@current_user if defined?(@current_user)
    reset_session
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    rt = session[:return_to]
    session[:return_to] = nil
    redirect_to(rt || default)
  end

  def init_nav_class
    @nav_class = Hash.new
  end
  
end
