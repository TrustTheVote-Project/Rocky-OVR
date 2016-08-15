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
require "#{Rails.root}/app/services/v3"
class Api::V3::PartnersController < Api::V3::BaseController

  def show(only_public = false)
    query = {
      :partner_id      => params[:id] || params[:partner_id],
      :partner_api_key => params[:partner_API_key] }

    jsonp V3::PartnerService.find(query, only_public)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end

  def show_public
    show(true)
  end

  def create
    partner = V3::PartnerService.create_record(params[:partner])
    jsonp :partner_id => partner.id.to_s
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.message.split(': ')[1]
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end
  
  
  def partner_id_validation
    if params[:partner_id].blank?
      jsonp({
        is_valid: false,
        message: "Missing Parameter: partner_id"
      }, status: 400)
    else
      partner = Partner.find_by_id(params[:partner_id])
      if partner
        jsonp({
          is_valid: true,
          partner_name: partner.name
        })
      else
        jsonp({
          is_valid: false
        })      
      end
    end
  end


end
