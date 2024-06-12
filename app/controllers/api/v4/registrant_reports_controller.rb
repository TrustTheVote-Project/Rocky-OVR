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
class Api::V4::RegistrantReportsController < Api::V4::BaseController
  def create
    query = {
      :partner_id       => params[:partner_id],
      :partner_api_key  => params[:partner_API_key],
      :since            => params[:since],
      :before           => params[:before],
      :email            => params[:email],
      :report_type      => params[:report_type],
      :uid              => params[:uid]
    }

    jsonp V4::RegistrationService.create_report(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)    
  end
  
  
  def gcreate
    query = {
      :gpartner_id       => params[:gpartner_id],
      :gpartner_api_key  => params[:gpartner_API_key],
      :since            => params[:since],
      :email            => params[:email],
      :report_type      => params[:report_type],
      :uid              => params[:uid]
    }
    jsonp V4::RegistrationService.create_report(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
  
  def show
    query = {
      :partner_id       => params[:partner_id],
      :partner_api_key  => params[:partner_API_key],
      :report_id        => params[:id]
    }
    jsonp V4::RegistrationService.get_report(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)        
  end
  
  def gshow
    query = {
      :partner_id       => params[:gpartner_id],
      :partner_api_key  => params[:gpartner_API_key],
      :report_id        => params[:id],
      :g_partner        => true
    }
    jsonp V4::RegistrationService.get_report(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)        
  end
  
  def download
    report = get_report(params[:partner_id], params[:partner_API_key])
    send_data report.read, filename: report.download_file_name, type: "text/csv"
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)        
  end
  
  def gdownload
    report = get_report(params[:gpartner_id], params[:gpartner_API_key])
    send_data report.read, filename: report.download_file_name, type: "text/csv"
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)        
  end

  private
  def get_report(id, api_key)
    partner = V4::PartnerService.find_partner(id, api_key)
    report = Report.find_by_id(params[:id])
    if report.nil? || report.partner != partner
      raise(ArgumentError.new(V4::RegistrationService::REPORT_PERMISSIONS_ERROR)) if report.partner != partner
    end
    return report
  end
  
end