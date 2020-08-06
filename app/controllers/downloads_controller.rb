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
class DownloadsController < RegistrationStep
  CURRENT_STEP = 6

  skip_before_filter :find_partner, only: :pdf
  
  def show
    find_registrant(:download)
    set_ab_test
    set_up_view_variables
    @attempt = (params[:cno] || 1).to_i
    @refresh_location = @attempt >= 10 ? registrant_finish_path(@registrant) : registrant_download_path(@registrant, :cno=>@attempt+1)
    if @registrant.mail_with_esig? && !@registrant.skip_mail_with_esig?
      redirect_to registrant_finish_url(@registrant)      
    elsif @registrant.pdf_ready?
      render "show"
    elsif @registrant.javascript_disabled?
      if @registrant.updated_at < 30.seconds.ago && !@registrant.email_address.blank?
        redirect_to registrant_finish_url(@registrant)
      else
        render "preparing"
      end
    else
      @uid = nil #@registrant.remote_uid
      @timeout = !@registrant.email_address.blank?
      render "preparing"
    end
  end

  def pdf
    find_registrant(:download)
    if !@registrant.pdf_ready?
      redirect_to registrant_finish_path(@registrant, not_ready: true)
    else
      set_ab_test
      set_up_view_variables
      @pdf_url = @registrant.download_pdf
      #redirect_to pdf_path
    end
  end
  
  def pdf_assistance
    find_registrant(:download)
    @registrant.queue_pdf_delivery
    # Render because we just assume it'll go through
  end
  

end
