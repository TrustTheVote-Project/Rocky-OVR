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
class Admin::GeoStatesController < Admin::BaseController
  

  def index
    @geo_states = GeoState.all
  end

  def edit
    @geo_state = GeoState[params[:id]]
  end

  def show
    @geo_state = GeoState[params[:id]]
    render :edit
  end

  def zip_codes
    @geo_state = GeoState[params[:id]]
    @zip_codes = ZipCodeCountyAddress.where(geo_state_id: @geo_state.id)
  end
  def check_zip_code
    @geo_state = GeoState[params[:id]]
    zcca = ZipCodeCountyAddress.where(zip: params[:zip_code]).first
    @region_result = zcca.check_address
    
    @zip_codes = ZipCodeCountyAddress.where(geo_state_id: @geo_state.id)
    render action: :zip_codes
  end

  def update
    @geo_state = GeoState[params[:id]]
    if @geo_state.update_attributes(geo_state_params)
      flash[:message] = "Updated #{@geo_state.name} settings"
    else
      flash[:warning] =  "Error updating #{@geo_state.name} settings"
    end
    redirect_to edit_admin_geo_state_path(@geo_state)
  end

  def remove_direct_mail_partner_id
    @geo_state = GeoState[params[:id]]
    @geo_state.direct_mail_partner_ids.delete(params[:partner_id])
    @geo_state.save
    partner = Partner.find_by_id(params[:partner_id])
    flash[:message] = "Removed partner #{params[:partner_id]}#{partner && ": #{partner.organization}"}"
    redirect_to edit_admin_geo_state_path(@geo_state)
  end

  def bulk_update
    catalist_update_dates = {}
    if catalist_update_file = params[:catalist_update_file]
      begin
        CSV.foreach(catalist_update_file.path, headers: true, col_sep: "\t") do  |row|
          catalist_update_dates[row["State"].to_s.downcase] = Date.parse(row["Release Date"])
        end
      rescue
        flash[:error] = "Expected tab delimited file with header row columns \"State\" and \"Release Date\""
      end
    end
    GeoState.all.each do |s|
      updated = false
      if params[:pdf_assistance_enabled] && params[:pdf_assistance_enabled][s.abbreviation]
        s.pdf_assistance_enabled = params[:pdf_assistance_enabled][s.abbreviation] == "1"
        updated = true
      end
      if params[:abr_deadline_passed] && params[:abr_deadline_passed][s.abbreviation]
        s.abr_deadline_passed = params[:abr_deadline_passed][s.abbreviation] == "1"
        updated = true
      end
      if params[:abr_splash_page] && params[:abr_splash_page][s.abbreviation]
        s.abr_splash_page = params[:abr_splash_page][s.abbreviation] == "1"
        updated = true
      end
      if updated
        catalist_updated_at = catalist_update_dates[s.abbreviation.downcase]
        s.catalist_updated_at = catalist_updated_at if catalist_updated_at
        s.save
      end
    end
    
    flash[:message] = "State Settings Updated"
    redirect_to action: :index
  end

  private

  def init_nav_class
    @nav_class = {geo_states: :current}
  end  

  def geo_state_params
    params.require(:geo_state).permit(
      :enable_direct_mail,
      :allow_desktop_signature,
      :add_direct_mail_partner_id,
      :state_voter_check_url
    )
  end
end
