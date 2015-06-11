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

describe QuestionsController do
  describe 'for UI-only deploys' do
    it "redirects to the core UI" do
      old_role = ENV['ROCKY_ROLE']
      ENV['ROCKY_ROLE'] = 'UI'
      get :edit
      response.should redirect_to("#{RockyConf.api_host_name}/login")
      ENV['ROCKY_ROLE'] = old_role
    end
  end
  
  describe "when logged in" do
    before(:each) do
      activate_authlogic
      @partner = FactoryGirl.create(:partner, :id => 5)
      PartnerSession.create(@partner)
    end

    describe "edit" do
      it "shows edit form" do
        get :edit
        assert_response :success
        assert_template "edit"
        assert_not_nil assigns[:partner]
      end
    end

    describe "update" do
      it "updates questions" do
        put :update, :partner => {
                        :survey_question_1_en => "What is your favorite color?",
                        :survey_question_1_es => "Cual es tu color favorito?",
                        :survey_question_2_en => "What is the average airspeed velocity of an unladen swallow?",
                        :survey_question_2_es => "",
                        :survey_question_1_ko => "KO Question 1?"
                      }
        assert_redirected_to partner_url
      end
    end
  end
end
