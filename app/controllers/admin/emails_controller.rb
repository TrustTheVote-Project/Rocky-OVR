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
class Admin::EmailsController < Admin::BaseController
  before_action :load_variables
  def index
  end
  
  def create
    @new_email = EmailAddress.new params[:email_address]
    @new_email.email_address = @new_email.email_address.to_s.strip.downcase
    
    @new_email.blacklisted=true
    if @new_email.save
      redirect_to admin_emails_path
    else
      render 'admin/emails/index'
    end
  end
  
  def destroy
    @email = EmailAddress.find params[:id]
    @email.destroy!
    flash[:success] = "Email #{@email.email_address} removed from block list"
    redirect_to admin_emails_path
  end
  
  
  private
  def load_variables
    @emails = EmailAddress.all.order(:email_address)
    @domains = EmailDomain.all.order(:domain)
    @new_email = EmailAddress.new
    @new_domain = EmailDomain.new
  end
  
  def init_nav_class
    @nav_class = {emails: :current}
  end
  
end