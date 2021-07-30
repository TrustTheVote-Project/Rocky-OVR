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
class ApprovalController < PartnerBase
  layout "partners"
  before_action :require_partner, :load_data


  def show
  end

  def update
    error = false

    @update_request.open rescue error = true

    flash = error ? { warning: "Invalid operation" } : {}
    redirect_to partner_branding_approval_path, flash: flash
  end

  def destroy
    error = false

    @update_request.delete rescue error = true

    flash = error ? { warning: "Invalid operation" } : {}
    redirect_to partner_branding_approval_path, flash: flash
  end

  def preview
    redirect_to current_partner.preview_custom_assets_link
  end

  private

  def load_data
    @partner = current_partner
    @update_request = BrandingUpdateRequest.new(@partner)
  end

  def preview_confirmation
    status = @partner.preview_assets_status
    if status != :updated
      I18n::t('partners.branding.preview_warning')[status];
    else
      ''
    end
  end

  helper_method :preview_confirmation
end
