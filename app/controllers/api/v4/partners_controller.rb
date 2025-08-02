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
require "#{Rails.root}/app/services/v4"
class Api::V4::PartnersController < Api::V4::BaseController

  def show(only_public = false)
    query = {
      :partner_id      => params[:id] || params[:partner_id],
      :partner_api_key => params[:partner_API_key] }

    jsonp V4::PartnerService.find(query, only_public)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end

  def show_public
    show(true)
  end

  def create
    partner = V4::PartnerService.create_record(partner_params)
    jsonp :partner_id => partner.id.to_s
  rescue V4::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.attribute
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end
  
  def validate_version
    min_version = RockyConf.ovr_states.PA.grommet_min_version || "3.0.0"
    if params[:version].blank?
      jsonp({
        errors: ["Missing Parameter: version"]
        }, status: 422)
    elsif Gem::Version.new(params[:version]) < Gem::Version.new(min_version)
      jsonp({
        is_valid: false,
        errors: ["App version must be at least #{min_version}"]
      })
    else
      jsonp({
        is_valid: true,
        errors: []
      })
    end
  end
  
  def partner_id_validation
    if params[:partner_id].blank? 
      jsonp({
        errors: ["Missing Parameter: partner_id"]
      }, status: 422)
    else
      partner = Partner.find_by_id(params[:partner_id])
      if partner && partner.enabled_for_grommet?
        locales = RockyConf.ovr_states.PA.languages || []
        deadline_messages = {}
        volunteer_messages = {}
        locales.each do |l| 
          deadline_messages[l] = I18n.t('states.custom.pa.registration_deadline_text', locale: l)
          volunteer_messages[l] = I18n.t('txt.registration.volunteer', organization: partner.organization, locale: l)
        end
        
        locations = CanvassingShift.location_options(partner)
        if locations.blank?
          locations = [["Default Location", 0]]
        end
        locations = locations.collect {|name, id| {id: id, name: name}}

        # TODO: should the jsonp method use JSON.generate for unencoded utf-8 responses?
        json_str = JSON.generate({
          is_valid: true,
          partner_name: partner.organization,
          valid_locations: locations,
          registration_deadline_date: RockyConf.ovr_states.PA.registration_deadline.strftime("%Y-%m-%d"),
          registration_notification_text: deadline_messages,
          volunteer_text: volunteer_messages,
          errors: []
        })
        begin
          Rails.logger.info("Responding to partnerIdValidation request for #{params[:partner_id]} with: #{json_str}")
        rescue
        end
        render json: json_str
      else
        begin
          Rails.logger.info("Responding to partnerIdValidation request for #{params[:partner_id]} with: #{{is_valid: false}}")
        rescue
        end
        jsonp({
          is_valid: false,
          partner_name: nil,
          valid_locations: [],
          registration_deadline_date: nil,
          registration_notification_text: {},
          volunteer_text: {},
          errors: ["Partner is not configured"]
        })      
      end
    end
  end

  protected
  def partner_params
    params[:partner] && !params[:partner].empty? ? params.require(:partner).permit! : {}
  end
end
