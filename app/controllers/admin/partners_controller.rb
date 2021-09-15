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
class Admin::PartnersController < Admin::BaseController

  def index
    if params[:partner_id] 
      if Partner.find_by_id(params[:partner_id])
        redirect_to admin_partner_path(params[:partner_id]) and return
      else
        flash[:warning] = "Partner ID #{params[:partner_id]} not found"
      end
    end
    @partners = Partner.standard.paginate(:page => params[:page], :per_page => 1000)
    @partner_zip = PartnerZip.new(nil)
  end

  def upload_registrant_statuses
    @partners = Partner.standard.paginate(:page => params[:page], :per_page => 1000)
    @partner_zip = PartnerZip.new(nil)
    
    state = GeoState.find(params[:geo_state])
    csv = params[:statuses_csv]
    RegistrantStatus.import_ovr_status!(csv.path, state, current_admin)
    
    @status_results = "Your results will be emailed to #{current_admin.email}"

    render action: :index
  end
  
  def add_user
    @partner = Partner.find(params[:id])
    @user = User.add_to_partner!(params[:email], @partner)
    if @user
      flash[:success] = "Added #{@user.email}"
    else
      flash[:warning] = "Error adding #{params[:email]} to this partner"
    end
    redirect_to admin_partner_path(@partner)
  end

  def remove_user
    @partner = Partner.find(params[:id])    
    @user = User.find_by_id(params[:user_id])
    if (@partner && @user)
      @partner_user = PartnerUser.where(partner: @partner, user: @user).first
      if @partner_user && @partner_user.delete
        flash[:success] = "Removed #{@user.email} from this partner"
        redirect_back_or_default admin_partner_path(@partner) 
        return
      end
    end
    flash[:warning] = "Error removing #{@user&.email} from this partner"
    redirect_back_or_default admin_partner_path(@partner) 
  end

  def new
    @partner = Partner.new
  end

  def show
    @partner = Partner.find(params[:id])
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def create
    @partner = Partner.new(partner_params)
    @partner.password = 'aBc123!@' + SecureRandom.hex(10) + 'a'
    if @partner.save
      update_email_templates(@partner, params[:template])
      update_email_template_subjects(@partner, params[:template_subject])
      update_custom_css(@partner, params[:css_files])
      flash[:message]= "Partner Created"
      redirect_to edit_admin_partner_path(@partner) 
    else
      flash.now[:warning]= "There was en error creating the partner"
      render :new
    end
  end

  def update
    @partner = Partner.find(params[:id])

    if @partner.update_attributes(partner_params)
      update_email_templates(@partner, params[:template])
      update_email_template_subjects(@partner, params[:template_subject])
      update_custom_css(@partner, params[:css_files])
      flash[:message]= "Partner Updated"
      redirect_to edit_admin_partner_path(@partner) 
    else
      flash.now[:warning]= "There was en error updating the partner"
      render :edit
    end
  end
  
  def regen_api_key
    @partner = Partner.find(params[:id])
    @partner.generate_api_key!
    redirect_to admin_partner_path(@partner)
  end

  def publish
    @partner = Partner.find(params[:id])
    publish_partner_assets(@partner)
    redirect_to admin_partners_path, flash: { success: 'Assets update finished' }
  end

  private

  def partner_params
    params[:partner] ? params.require(:partner).permit! : {}
  end

  def update_email_templates(partner, templates)
    (templates || {}).each do |name, body|
      EmailTemplate.set(partner, name, body)
    end
  end
  def update_email_template_subjects(partner, subjects)
    (subjects || {}).each do |name, subject|
      EmailTemplate.set_subject(partner, name, subject)
    end
  end

  def update_custom_css(partner, css_files)
    paf = PartnerAssetsFolder.new(partner)
    (css_files || {}).each do |name, data|
      paf.update_css(name, data)
    end
  end

end
