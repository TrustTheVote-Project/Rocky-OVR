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

describe RegistrantsController do
  before(:each) do
    Partner.stub(:find) do |arg|
      p = Partner.new(:id=>arg)
      p.stub(:to_param) { arg.to_s }
      p.stub(:id) { arg }
      p
    end
    Partner.stub(:find).with(nil).and_raise("Not Found")
  end
  
  describe "widget loader" do
    render_views

    it "generates bootstrap javascript targeted to server host" do
      request.stub(:protocol) { "http://" }
      request.stub(:host_with_port) { "example.com:3000" }
      get :widget_loader, :format => "js"
      assert_response :success
      assert_template "widget_loader"
      assert_match %r{createElement}, response.body
    end
  end

  describe "landing" do
    before(:each) do 
      request.stub(:protocol) { "https://" }      
    end
    it "redirects to /new, and leaves out partner when none given" do
      get :landing
      assert_redirected_to new_registrant_url(:protocol => "https")
    end

    it "keeps partner, locale, source, tracking, home_zip_code, email_address, state, first_name, last_name, collectemailaddress and short_form params when redirecting" do
      get :landing, :partner => "2"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2")
      get :landing, :locale => "es"
      assert_redirected_to new_registrant_url(:protocol => "https", :locale => "es")
      get :landing, :source => "email"
      assert_redirected_to new_registrant_url(:protocol => "https", :source => "email")
      get :landing, :tracking => "trackid"
      assert_redirected_to new_registrant_url(:protocol => "https", :tracking => "trackid")
      get :landing, :collectemailaddress => "yesnooptional"
      assert_redirected_to new_registrant_url(:protocol => "https", :collectemailaddress => "yesnooptional")
      get :landing, :source => "email", :tracking=>"trackid"
      assert_redirected_to new_registrant_url(:protocol => "https", :source => "email", :tracking=>"trackid")
      get :landing, :partner => "2", :locale => "es"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es")
      get :landing, :partner => "2", :locale => "es", :source => "email"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email")
      get :landing, :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid")
      get :landing, :partner => "2", :locale => "es", :source => "email", :short_form=>"1"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email", :short_form=>"1")
      get :landing, :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid", :short_form=>"0"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid", :short_form=>"0")
      
      get :landing, :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid", :short_form=>"0", first_name: "first", last_name: "last", state: "CA", home_zip_code: "90210", email_address: "email@example.com"
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid", :short_form=>"0", first_name: "first", last_name: "last", state: "CA", home_zip_code: "90210", email_address: "email@example.com")
      
    end


    it "assumes default partner when partner given doesn't exist" do
      non_existent_partner_id = "43243243"
      Partner.stub(:find).with("43243243").and_raise("Not Found")
      assert Partner.find_by_id(non_existent_partner_id).nil?
      get :landing, :partner => non_existent_partner_id.to_s
      assert_redirected_to new_registrant_url(:protocol => "https", :partner => Partner::DEFAULT_ID)
    end
  end

  describe "#new" do
    it "should show the step 1 input form" do
      get :new
      assert !assigns[:registrant].nil?
      assert_template "show"
    end

    it "should start with partner id, locale, tracking source, collectemailaddress and partner tracking id" do
      get :new, :locale => 'es', :partner => '2', :source => 'email', :tracking=>"trackid", :collectemailaddress=>"yes"
      reg = assigns[:registrant]
      assert_equal 'es', reg.locale
      assert_equal 2, reg.partner_id
      assert_equal "2", reg.partner.id.to_s
      assert_equal 'email', reg.tracking_source
      assert_equal 'trackid', reg.tracking_id
      assert_equal 'yes', reg.collect_email_address
    end

    it "should default partner id to RTV" do
      get :new
      reg = assigns[:registrant]
      assert_equal Partner::DEFAULT_ID, reg.partner_id
    end

    it "should default locale to English" do
      get :new
      reg = assigns[:registrant]
      assert_equal 'en', reg.locale
    end
    
    it 'should sanitize locale' do
      get :new, :locale=>'nv'
      assert_equal 'en', assigns[:locale]
    end

    describe "keep initial params in hidden fields" do
      render_views

      it "should keep partner, locale, tracking source, tracking id and short_form" do
        get :new, :locale => 'es', :partner => '2', :source => 'email', :tracking=>'trackid', :short_form=>true
        assert_equal '2', assigns[:partner_id].to_s
        assert_equal 'es', assigns[:locale]
        assert_equal 'email', assigns[:source]
        assert_equal 'trackid', assigns[:tracking]
        assert_equal true, assigns[:short_form]
        assert_select "input[name=partner][value=2]"
        assert_select "input[name=locale][value=es]"
        assert_select "input[name=source][value=email]"
        assert_select "input[name=tracking][value=trackid]"
        assert_select "input[name=short_form][value=true]"
      end
    end

    describe "partner logo" do
      render_views

      it "should not show partner banner or logo for primary partner" do
        get :new, :partner => Partner::DEFAULT_ID.to_s
        assert_select "#header.partner", 0
        assert_select "#partner-logo", 0
      end

      it "should show partner banner and logo for non-primary partner with custom logo on long form" do
        partner = Partner.new
        partner.id = 1234
        partner.stub(:custom_logo?) { true }
        partner.stub(:logo) { "http://abc123" }
        partner.stub(:use_long_form?) { true }
        Partner.stub(:find_by_id).with(partner.to_param).and_return(partner)
        get :new, :partner => partner.to_param

        assert_response :success
        assert_select "#header.partner"
        assert_select "#partner-logo img[src=http://abc123]"
      end
      it "should show partner banner and logo for non-primary partner with custom logo on short form" do
        partner = Partner.new
        partner.id = 1234
        partner.stub(:custom_logo?) { true }
        partner.stub(:logo) { "http://abc123" }
        Partner.stub(:find_by_id).with(partner.to_param).and_return(partner)
        get :new, :partner => partner.to_param

        assert_response :success
        assert_select "#header.partner[style=background-image: url('http://abc123')]"
      end
    end
      
    
    context "from a mobile browser" do  
      before(:each) do
        MobileConfig.stub(:is_mobile_request?).and_return(true)
      end
      it "redirects to the url with partner='1' when no other parameters are given" do
        get :new
        response.should render_template :show
      end
      it "shows mobile for another partner even if short_form is false" do
        partner = Partner.new
        partner.stub(:custom_logo?) { true }
        partner.stub(:logo) { "http://abc123" }
        Partner.stub(:find_by_id).with(partner.to_param).and_return(partner)
        get :new, :partner => partner.to_param, short_form: false
        
        response.should render_template :show
      end
    end
    
    context "when using a short form" do
      let(:params) { {
        short_form: true
      }}
      let(:registrant) { FactoryGirl.create(:step_1_registrant)}
      it "renders the same template" do
        get :new, params
        assert_template "show"
      end
      context "when email and zip are provided" do
        let(:params) { {
          short_form: true,
          email_address: "email@example.com",
          home_zip_code: "90210"
        }}
        it "goes to the create method" do
          expect(controller).to receive(:create) { controller.render text: '' }
          get :new, params
        end
      end
      context "when email and state are provided" do
        let(:params) { {
          short_form: true,
          email_address: "email@example.com",
          state: "CA"
        }}
        it "goes to the create method" do
          expect(controller).to receive(:create) { controller.render text: '' }
          get :new, params
        end
      end
      context "when zip provided with collectemailaddress=no" do
        let(:params) { {
          short_form: true,
          collectemailaddress: "no",
          home_zip_code: "02113"
        }}
        it "goes to the create method" do
          expect(controller).to receive(:create) { controller.render text: '' }
          get :new, params
        end
      end
      context "when state is not enabled" do
        let(:params) { {
          short_form: true,
          state: "WY"
        }}
        it "redirects to ineligible state" do
          get :new, params
          expect(response).to redirect_to registrant_ineligible_url(assigns[:registrant])          
        end
      end
    end
    
  end

  describe "#create" do
    render_views

    before(:each) do
      @partner = FactoryGirl.create(:partner)
      @reg_attributes = FactoryGirl.attributes_for(:step_1_registrant)
      @reg_attributes.delete(:status)
    end

    it "should create a new registrant and complete step 1" do
      post :create, :registrant => @reg_attributes
      assert !assigns[:registrant].nil?
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should set partner_id, locale, tracking_source, tracking_id, collectemailaddress and short_form" do
      @reg_attributes.delete(:locale)
      @reg_attributes.delete(:partner_id)
      post :create, :registrant => @reg_attributes, :partner => @partner.id, :locale => "es", :source => "email", :tracking=>"trackid", :short_form=>"1", :collectemailaddress=>'yes'
      assert_equal @partner.id, assigns[:registrant].partner_id
      assert_equal "es", assigns[:registrant].locale
      assert_equal "email", assigns[:registrant].tracking_source
      assert_equal "trackid", assigns[:registrant].tracking_id
      assert_equal "yes", assigns[:registrant].collect_email_address
      assert_equal true, assigns[:registrant].short_form?
    end

    it "should reject invalid input and show form again" do
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => "")
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].new_record?, assigns[:registrant].inspect
      assert_template "show"
    end

    it "should keep partner, locale, source, collectemailaddress and tracking for next attempt" do
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => ""), :partner => "2", :locale => "es", :source => "email", :tracking=>"trackid", :collectemailaddress=>'yes'
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].new_record?, assigns[:registrant].inspect
      assert_template "show"
      assert_select "input[name=partner][value=2]"
      assert_select "input[name=locale][value=es]"
      assert_select "input[name=source][value=email]"
      assert_select "input[name=tracking][value=trackid]"
      assert_select "input[name=collectemailaddress][value=yes]"
    end

    it "should reject ineligible registrants" do
      north_dakota_zip = "58001"
      post :create, :registrant => @reg_attributes.merge(:home_zip_code => north_dakota_zip)
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].ineligible?
      assert assigns[:registrant].ineligible_non_participating_state?
      assert assigns[:registrant].rejected?
      assert_redirected_to registrant_ineligible_url(assigns[:registrant])
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_4_registrant)
    end

    it "should update registrant and complete step 1" do
      put :update, :id => @registrant.to_param, :registrant => {:email_address => "new@example.com"}
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].step_1?
      assert_redirected_to registrant_step_2_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :id => @registrant.to_param, :registrant => {:email_address => nil}
      assert assigns[:registrant].step_1?
      assert assigns[:registrant].reload.step_4?
      assert_template "show"
    end

    it "should reject ineligible registrants" do
      north_dakota_zip = "58001"
      put :update, :id => @registrant.to_param, :registrant => {:home_zip_code => north_dakota_zip}
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].ineligible?
      assert assigns[:registrant].ineligible_non_participating_state?
      assert assigns[:registrant].rejected?
      assert_redirected_to registrant_ineligible_url(assigns[:registrant])
    end
  end

  describe "registration step" do
    describe "missing registration" do
      it "should show 404" do
        assert_nil Registrant.find_by_uid("987654321")
        expect {
          get :show, :id => "987654321"
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "completed registration" do
      it "should not be visible" do
        reg = FactoryGirl.create(:completed_registrant)
        expect {
          get :show, :id => reg.to_param
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "under-18 finished registration" do
      it "should not be visible" do
        reg = FactoryGirl.create(:under_18_finished_registrant)
        expect {
          get :show, :id => reg.to_param
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "abandoned registration" do
    render_views

    it "should show a timeout page" do
      reg = FactoryGirl.create(:step_1_registrant, :abandoned => true, :locale => "es", :partner_id=>2)
      get :show, :id => reg.to_param
      assert_redirected_to registrants_timeout_url(:partner => reg.partner.id, :locale => reg.locale)
    end
  end
end
