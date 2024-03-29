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

describe StateCustomization do
  let(:state) { GeoState.new(:abbreviation=>"AA") }
  describe "self.for(state)" do
    context "when there's no class defined" do
      before(:each) do
        StateCustomization.stub(:class_exists?).and_return(false)
      end
      it "returns a new instance of the StateCustomization class" do
        StateCustomization.for(state).class.should == StateCustomization
        
      end
    end
    context "when there is a class defined" do
      before(:each) do
        class AA < StateCustomization
        end
      end
      it "returns a new instance of the specific class"  do
        StateCustomization.for(state).class.should == AA
      end
    end
  end
  
  describe "self.class_exists?(class_name)" do
    it "returns true for classes" do
      StateCustomization.send(:class_exists?, "StateCustomization").should be_truthy
    end
    it "returns false for modules" do
      StateCustomization.send(:class_exists?, "ActiveRecord").should be_falsey
    end
    it "returns false when can't be instantiated" do
      StateCustomization.send(:class_exists?, "AsdfsAsdf").should be_falsey
    end
  end
  
  describe "initialize" do
    it "sets the state" do
      sc = StateCustomization.new(state)
      sc.state.should == state
    end
  end
  
  describe "online_reg_url(registrant)" do
    let(:sc) { StateCustomization.new(state) }
    before(:each) do
      state.stub(:online_registration_url).and_return("state-url")
    end
    it "returns the state's configured url" do
      sc.online_reg_url(nil).should == "state-url"
    end
    
  end
  
  describe "redirect_to_online_reg_url(registrant)" do
    let(:sc) { StateCustomization.new(state) }
    it "returns whether the state should redirect" do
      sc.redirect_to_online_reg_url(nil).should be_falsey
      
      settings = double("Setting")
      sc.stub(:ovr_settings).and_return(settings)
      
      settings.stub(:redirect_to_online_reg_url).and_return(true)
      sc.redirect_to_online_reg_url(nil).should be_truthy

      sc.stub(:redirect_to_online_reg_url).and_return(false)
      sc.redirect_to_online_reg_url(nil).should be_falsey
    end
    
  end

  describe "has_ovr_pre_check?(registrant)" do
    let(:sc) { StateCustomization.new(state) }
    it "returns false" do
      sc.has_ovr_pre_check?(nil).should be_falsey
    end
    
  end
  
  describe "ovr_pre_check(registrant)" do
    let(:sc) { StateCustomization.new(state) }
    it "raises a not implemented error" do
      expect { sc.ovr_pre_check(nil) }.to raise_error("Not Implemented")
    end
  end
  
  describe "enabled_for_language?" do
    let(:sc) { StateCustomization.new(state) }
    let(:ovr_settings) { nil }
    let(:reg) { nil }
    let(:lang) { "a" }
    before(:each) do
      allow(sc).to receive(:ovr_settings) { ovr_settings }
      allow(sc).to receive(:require_id?) { false }
      allow(sc).to receive(:require_age_confirmation?) { false }
      
    end
    subject { sc.enabled_for_language?(lang, reg) }
    context "when reg is null" do
      context "if ovr_settings is not configured" do
        let(:ovr_settings) { nil }
        it { should eq(true) }
      end
      context "if ovr_settings has emtpy languages key" do
        let(:ovr_settings) {{"languages"=>[]}}
        it { should eq(true) }
      end
      context "if ovr_settings doesn't include the language key" do
        let(:ovr_settings) {{"languages"=>["not-the-lang"]}}
        it { should eq(false) }
      end
      context "if ovr_settings has emtpy languages key" do
        let(:ovr_settings) {{"languages"=>["b","a"]}}
        it { should eq(true) }
      end
    end
    context "when reg is present" do
      let(:reg) { double(Registrant) }
      context "when id is required" do
        before(:each) do
          allow(sc).to receive(:require_id?) { true }
        end
        it "returns false if the reg does not have id" do
          expect(reg).to receive(:has_state_license?) { false }
          expect(subject).to eq(false)
        end        
      end
      context "require_age_confirmation?" do
        before(:each) do
          allow(sc).to receive(:require_age_confirmation?) { true }
        end
        it "returns false if the reg is not 18" do
          expect(reg).to receive(:will_be_18_by_election?) { false }
          expect(subject).to eq(false)          
        end
      end
    end
  end
  
  
end
