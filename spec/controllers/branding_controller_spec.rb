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
require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe BrandingController do
  before(:each) do
    rspec_partner_auth
  end

  it 'renders branding template' do
    get :show
    expect(response).to render_template('show')
  end

  describe 'editing' do
    before(:each) do
      @fs3 = FakeS3.new
      allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(@fs3)
    end

    it 'uploads custom css files' do
      files = [PartnerAssets::APP_CSS, PartnerAssets::REG_CSS, PartnerAssets::PART_CSS].map do |css|
        Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'partner_css', css))
      end

      expect(@fs3.files.count).to be_eql 0

      request.env["HTTP_REFERER"] = "example.com"
      post :update, css_files: {application: files[0], registration: files[1], partner: files[2]}

      paths = [
          @partner.application_css_path(:preview),
          @partner.registration_css_path(:preview),
          @partner.partner_css_path(:preview)
      ]
      expect(@fs3.files.count).to be_eql 3
      expect(@fs3.files.map &:key).to match_array(paths)
      expect(@fs3.files.map &:body).to match_array(['h1 { }', 'h2 { }', 'h3 { }'])
    end

    it 'uploads custom assets' do
      file = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/files/partner_logo.jpg'))

      expect(@fs3.files.count).to be_eql 0

      request.env["HTTP_REFERER"] = "example.com"
      post :update, {file: file}

      expect(@fs3.files.count).to be_eql 1
      expect(@fs3.files[0].key).to be_eql File.join(@partner.partner_path, 'preview', 'partner_logo.jpg')
    end

    it 'updates emails templates' do
      expect(EmailTemplate).to receive(:set).with(@partner, 'template_name1', 'value1')
      expect(EmailTemplate).to receive(:set).with(@partner, 'template_name2', 'value2')
      expect(EmailTemplate).to receive(:set_subject).with(@partner, 'template_subj1', 'value3')
      expect(EmailTemplate).to receive(:set_subject).with(@partner, 'template_subj2', 'value4')
      
      request.env["HTTP_REFERER"] = "example.com"
      post :update,
           template: {'template_name1' => 'value1', 'template_name2' => 'value2'},
           template_subject: {'template_subj1' => 'value3', 'template_subj2' => 'value4'}
    end
  end
end
