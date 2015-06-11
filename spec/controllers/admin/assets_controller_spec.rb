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
require 'rails_helper'

describe Admin::AssetsController do

  before(:each) { @paf = double(PartnerAssetsFolder) }
  before(:each) { @partner = FactoryGirl.create(:partner) }
  before(:each) { controller.stub(:assets_folder) { @paf } }

  describe 'index' do
    before  { @paf.stub(:list_assets) { [] } }
    before  { get :index, :partner_id => @partner }
    specify { assigns(:assets).should be }
    it      { should render_template :index }
  end

  describe 'destroy' do
    before  { @paf.stub(:delete_asset).with('application.css') }
    before  { delete :destroy, :partner_id => @partner, :id => 0, :name => 'application.css' }
    it      { should redirect_to admin_partner_assets_path(@partner) }
  end

  describe 'create' do
    before  { @file = fixture_files_file_upload('/sample.css') }
    before  { @paf.stub(:update_asset).with('sample.css', @file) }
    before  { post :create, :partner_id => @partner, :asset => { :file => @file } }
    it      { should redirect_to admin_partner_assets_path(@partner) }
  end

  describe 'create without a file' do
    before  { post :create, :partner_id => @partner }
    it      { should redirect_to admin_partner_assets_path(@partner) }
  end
end
