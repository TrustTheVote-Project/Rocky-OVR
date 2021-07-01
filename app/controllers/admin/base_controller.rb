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
class Admin::BaseController < ApplicationController

  layout 'admin'

  skip_before_filter :authenticate_everything
  before_filter :authenticate #, :if => lambda { !%w{ development test }.include?(Rails.env) }
  before_filter :check_mfa
  before_filter :init_nav_class

  helper_method :current_admin

  def reset_admin_passwords
    current_admin_session.destroy
    Admin.all.each do |a|
      # TODO - also change the password so login doesn't work?
      a.password = a.password_confirmation = 'aBc123!@' + SecureRandom.hex(10) + 'a'
      a.save!
      Notifier.admin_password_reset_required(a).deliver_now
    end
    current_admin_session.destroy
    flash[:message] = "Admin password reset instructions sent."
    redirect_to '/admin'
  end

  private

  def authenticate
    unless current_admin
      store_location
      redirect_to admin_login_path
    end
  end

  def check_mfa
    if !(admin_mfa_session = AdminMfaSession.find) && (admin_mfa_session ? admin_mfa_session.record == current_admin : !admin_mfa_session)
      store_location
      redirect_to new_admin_mfa_session_path
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

  def init_nav_class
    @nav_class = Hash.new
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def publish_partner_assets(partner)
    partner.folder.publish_sub_assets(:preview)
    EmailTemplate.publish_templates(partner)
    partner.replace_system_css_live = partner.replace_system_css_preview
    partner.update_attributes(whitelabeled: true) unless partner.whitelabeled?
  end
  

end
