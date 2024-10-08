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

describe Step4Controller do
  before(:each) do
    Partner.any_instance.stub(:valid_api_key?).and_return(true)
  end
  
  describe "#show" do
    it "should show the step 4 input form" do
      reg = FactoryGirl.create(:step_3_registrant)
      get :show, params: {:registrant_id => reg.to_param}
      assert assigns[:registrant].step_3?
      assert !assigns[:question_1].nil?
      assert !assigns[:question_2].nil?
      assert_template "show"
    end

    it "gets the questions for the current locale" do
      reg = FactoryGirl.create(:step_3_registrant)
      reg.partner.survey_question_1_en = "In English?"
      reg.partner.survey_question_1_es = "En Espanol?"
      reg.partner.save
      get :show, params: {:registrant_id => reg.to_param}
      assert_equal "In English?", assigns[:question_1]
      reg.locale = "es"
      reg.save(:validate=>false)
      get :show, params: {:registrant_id => reg.to_param}
      assert_equal "En Espanol?", assigns[:question_1]
    end

    describe "when partner wants volunteers" do
      render_views
      it "should show volunteer checkbox" do
        partner = FactoryGirl.create(:partner, :partner_ask_for_volunteers => true)

        reg = FactoryGirl.create(:step_3_registrant, :partner_id => partner.to_param)
        get :show, params: {:registrant_id => reg.to_param}

        assert_select "#registrant_partner_volunteer"
      end
    end

    describe "when partner does not want volunteers" do
      render_views
      it "should show volunteer checkbox" do
        partner = FactoryGirl.create(:partner, :ask_for_volunteers => false)

        reg = FactoryGirl.create(:step_3_registrant, :partner_id => partner.to_param)
        get :show, params: {:registrant_id => reg.to_param}

        assert_select "#registrant_volunteer", 0
      end
    end
    context "when there is an ovr pre_check" do
      let(:reg) { FactoryGirl.create(:step_3_registrant) }
      before(:each) do
        reg.stub(:has_ovr_pre_check?).and_return(true)
        reg.stub(:inspect)
        reg.stub(:ovr_pre_check) do
          reg.inspect
        end
        Registrant.stub(:find_by_param!).and_return(reg)
      end
      
      it "should run the registrant's OVR precheck instead of the redirect" do
        reg.should_receive(:inspect)
        get :show, params: {:registrant_id => reg.to_param}
        assert_template("show")
      end
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = FactoryGirl.create(:step_3_registrant)
    end

    it "should update registrant and complete step 4 when using long form" do
      put :update, params: {:registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_4_registrant).reject {|k,v| k == :status }.merge(short_form: 0)}
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].step_4?
      assert_redirected_to registrant_step_5_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again when using long form" do
      put :update, params: {:registrant_id => @registrant.to_param, :registrant => FactoryGirl.attributes_for(:step_4_registrant, :state_id_number => nil).reject {|k,v| k == :status }.merge(short_form: 0)}
      assert assigns[:registrant].step_4?
      assert assigns[:registrant].reload.step_3?
      assert assigns[:show_fields] == "1"
      assert_template "show"
    end
    
    it "should show the state-specific system when registrant_state_online_registration button is pressed" do
      put :update, params: {
        :registrant_id => @registrant.to_param, 
                   :registrant => FactoryGirl.attributes_for(:step_4_registrant, :has_state_license=>true).reject {|k,v| k == :status },
                   :registrant_state_online_registration => ""
      }
      assert !assigns[:registrant].nil?
      assert assigns[:registrant].step_4?
      assert assigns[:registrant].using_state_online_registration?
      assert_redirected_to registrant_state_online_registration_url(assigns[:registrant])
    end
  end

  describe "#find_registrant" do
    let(:reg) { FactoryGirl.create(:step_3_registrant) }
    before(:each) do
      Registrant.stub(:find_by_param!).and_return(reg)
      reg.stub(:has_ovr_pre_check?).and_return(true)
    end
    context "when reg has_ovr_pre_check" do
      it "decorates the registrant" do
        reg.should_receive(:decorate_for_state).with(controller)
        controller.send(:find_registrant)
      end
    end
  end

end
