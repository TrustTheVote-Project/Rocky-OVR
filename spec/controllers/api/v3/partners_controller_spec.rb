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
require File.expand_path(File.dirname(__FILE__) + '/../../../rails_helper')

describe Api::V3::PartnersController do

  describe 'show' do
    it 'should catch errors' do
      expect_api_error :message => 'error'
      partner { raise ArgumentError.new('error') }
    end

    it 'should return partner details' do
      expect_api_response :response
      partner { :response }
    end
  end

  describe 'show public' do
    it 'should return only public data' do
      expect_api_response :response
      public_partner { :response }
    end
  end

  describe "#create" do
    it "should return the ID of the created partner" do
      expect_api_response :partner_id => "2342"
      partner = double(Partner)
      partner.stub(:id) { 2342 }
      new_partner { partner }
    end
    it 'should catch invalid fields' do
      expect_api_error :message => "Error message", :field_name => "invalid_field"
      new_partner { raise V3::RegistrationService::ValidationError.new('invalid_field', 'Error message') }
    end
    it 'should report invalid parameter type' do
      expect_api_error :message => "Invalid parameter type", :field_name => "attr"
      new_partner { raise(ActiveRecord::UnknownAttributeError.new(Partner.new, 'attr')) }
    end

  end

  describe '#partner_id_validation' do
    context 'when partner_id is valid' do
      let(:query) {{
        :partner_id=>'1',
      }}
      let(:mock_partner) { double(Partner, :organization=>"Partner Org Name")}
      before(:each) do
        allow(Partner).to receive(:find_by_id).with('1').and_return(mock_partner)
        allow(mock_partner).to receive(:enabled_for_grommet?).and_return(true)
        allow(mock_partner).to receive(:custom_data).and_return({
          "canvassing_session_timeout_length" => 300,
          "canvassing_validation_timeout_length" => 2880
        })
      end
      context 'when partner is allowed' do
        subject { get :partner_id_validation, params: query, as: 'json' }
        it "returns a 200" do
          expect(subject.status).to eq(200)
        end
        it "returns a JSON body with is_valid=true" do
          expect(JSON.parse(subject.body)["is_valid"]).to eq(true)
        end
        it "returns a JSON body with partner_name='Partner Org Name'" do
          expect(JSON.parse(subject.body)["partner_name"]).to eq("Partner Org Name")
        end
        it "returns a JSON body with session_timeout_length" do
          expect(JSON.parse(subject.body)["session_timeout_length"]).to eq(300)
        end
        it "returns a JSON body with validation_timeout_length" do
          expect(JSON.parse(subject.body)["validation_timeout_length"]).to eq(2880)
        end
        it "returns a JSON body with registration_deadline_date as a string representing the deadline" do
          expect(JSON.parse(subject.body)["registration_deadline_date"]).to eq(RockyConf.ovr_states.PA.registration_deadline.strftime("%Y-%m-%d"))
        end        
        it "returns a JSON body with registration_notification_text as a hash of locale-string pairs" do
          expect(JSON.parse(subject.body)["registration_notification_text"]["en"]).to eq(I18n.t('states.custom.pa.registration_deadline_text', locale: 'en'))          
          expect(JSON.parse(subject.body)["registration_notification_text"]["es"]).to eq(I18n.t('states.custom.pa.registration_deadline_text', locale: 'es'))          
        end
        it "returns a JSON body with volunteer_text as a hash of locale-string pairs" do
          expect(JSON.parse(subject.body)["volunteer_text"]["en"]).to eq(I18n.t('txt.registration.volunteer', organization: mock_partner.organization,  locale: 'en'))          
          expect(JSON.parse(subject.body)["volunteer_text"]["es"]).to eq(I18n.t('txt.registration.volunteer', organization: mock_partner.organization, locale: 'es'))          
        end
      end
      context 'when parter is not allowed' do
        let(:query) {{
          :partner_id=>'1',
        }}
        before(:each) do
          allow(mock_partner).to receive(:enabled_for_grommet?).and_return(false)
        end
        subject { get :partner_id_validation, params: query, as: 'json' }
        it "returns a 200" do
          expect(subject.status).to eq(200)
        end
        it "returns a JSON body with is_valid=false" do
          expect(JSON.parse(subject.body)["is_valid"]).to eq(false)
        end
        it "returns a JSON body without partner_name key" do
          expect(JSON.parse(subject.body)).not_to have_key("partner_name")
        end
        
      end
    end
    context 'when partner_id is invalid' do
      let(:query) {{
        :partner_id=>'1',
      }}
      before(:each) do
        allow(Partner).to receive(:find_by_id).with('1').and_return(nil)
      end
      subject { get :partner_id_validation, params: query, as: 'json' }
      it "returns a 200" do
        expect(subject.status).to eq(200)
      end
      it "returns a JSON body with is_valid=false" do
        expect(JSON.parse(subject.body)["is_valid"]).to eq(false)
      end
      it "returns a JSON body without partner_name key" do
        expect(JSON.parse(subject.body)).not_to have_key("partner_name")
      end
      
    end
    context 'when partner_id is missing' do
      let(:query) {{
        :partner_id_wrong_param=>'1',
      }}
      subject { get :partner_id_validation, params: query, as: 'json' }
      it "returns a 400" do
        expect(subject.status).to eq(400)
      end
      it "returns a JSON body with message=Missing Parameter: partner_id" do
        expect(JSON.parse(subject.body)["is_valid"]).to eq(false)
        expect(JSON.parse(subject.body)["message"]).to eq("Missing Parameter: partner_id")
      end
    end
  end

  private

  def partner(&block)
    query = { :partner_id => "1", :partner_api_key => nil }
    V3::PartnerService.stub(:find).with(query, false, &block)
    get :show, :as => 'json', params: {:id=>1}
  end

  def public_partner(&block)
    query = { :partner_id => nil, :partner_api_key => nil }
    V3::PartnerService.stub(:find).with(query, true, &block)
    get :show_public, :as => 'json'
  end

  def new_partner(&block)
    data = {}
    V3::PartnerService.stub(:create_record).with(data, &block)
    post :create, :as => 'json', params: {:partner => data}
  end


end
