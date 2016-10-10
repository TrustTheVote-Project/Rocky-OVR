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
class Admin::WhitelabelController < Admin::BaseController

  def requests
    @requests = {
        open: BrandingUpdateRequest.all.select { |r| r.open? },
        recently_closed: BrandingUpdateRequest.recently_closed
    }
  end

  def approve_request
    @partner = Partner.find(params[:partner_id])
    req = BrandingUpdateRequest.new(@partner)
    publish_partner_assets(@partner)
    req.done
    redirect_to requests_admin_whitelabel_path, flash: { success: "Assets update finished [id=#{@partner.id}]" }
  end

  def reject_request
    @partner = Partner.find(params[:partner_id])
    req = BrandingUpdateRequest.new(@partner)
    req.reject
    redirect_to requests_admin_whitelabel_path, flash: { success: "Partner's request rejected [id=#{@partner.id}]" }
  end
end