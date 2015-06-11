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
require File.dirname(__FILE__) + "/../rails_helper"
require 'hpricot'

describe ApplicationHelper do
  describe "partner_locale_options" do
    it "shows partner, locale and source" do
      opts = helper.partner_locale_options(2, "es", "email")
      assert_equal 2, opts[:partner]
      assert_equal "es", opts[:locale]
      assert_equal "email", opts[:source]
    end

    it "shows partner but not default locale" do
      opts = helper.partner_locale_options(2, "en", nil)
      assert_equal 2, opts[:partner]
      assert_nil opts[:locale]
    end

    it "shows locale but not default partner" do
      opts = helper.partner_locale_options(1, "es", nil)
      assert_nil opts[:partner]
      assert_equal "es", opts[:locale]
    end

    it "shows neither default partner nor default locale" do
      opts = helper.partner_locale_options(1, "en", nil)
      assert_nil opts[:partner]
      assert_nil opts[:locale]
    end

    it "omits blank source" do
      opts = helper.partner_locale_options(2, "es", nil)
      assert !opts.has_key?(:source)
    end
  end

  describe "partner_css" do
    it "should return default stylesheets" do
      helper.partner_css(nil).should == [ 'application', 'registration' ]
    end

    it "should return default stylesheets for non-whitelabled partner" do
      partner = FactoryGirl.build(:partner, :whitelabeled => false)
      helper.partner_css(partner).should == [ 'application', 'registration' ]
    end

    it "should return custom application css" do
      partner = FactoryGirl.build(:partner, :whitelabeled => true)
      partner.stub(:application_css_present?) { true }
      partner.stub(:application_css_url) { 'app.css' }
      helper.partner_css(partner).should == [ 'app.css', 'registration' ]
    end

    it "should return custom registration css" do
      partner = FactoryGirl.build(:partner, :whitelabeled => true)
      partner.stub(:registration_css_present?) { true }
      partner.stub(:registration_css_url) { 'reg.css' }
      helper.partner_css(partner).should == [ 'application', 'reg.css' ]
    end
    
    it "should return custom partner css" do
      partner = FactoryGirl.build(:partner, :whitelabeled => true)
      partner.stub(:application_css_present?) { true }
      partner.stub(:partner_css_present?) { true }
      partner.stub(:application_css_url) { 'app.css' }
      partner.stub(:partner_css_url) { 'partner.css' }
      helper.partner_css(partner).should == ['app.css', 'registration', 'partner.css']
    end
  end

  describe "registrant_css" do
    context "when @locale is provided" do
      before(:each) do
        @locale = "en"
        @registrant = nil
      end
      context "in english" do
        it "returns an empty array" do
          helper.registrant_css.should == []
        end
      end
      context "in another language" do
        before(:each) do
          @locale = "es"
        end
        context "without a css file" do
          before(:each) do
            File.stub(:exists?).with(Translation.css_path("es")).and_return(false)
          end
          it "returns an empty array" do
            helper.registrant_css.should == []
          end
        end
        context "with a css file" do
          before(:each) do
            File.stub(:exists?).with(Translation.css_path("es")).and_return(true)
          end
          it "returns the es css file" do
            helper.registrant_css.should == ["locales/es"]
          end
        end
      end
    end
    context "when @locale is not provided" do
      before(:each) do
        @locale = nil
        @registrant = Registrant.new
      end
      context "in english" do
        it "returns an empty array" do
          helper.registrant_css.should == []
        end
      end
      context "in another language" do
        before(:each) do
          @registrant.locale = 'es'
        end
        context "without a css file" do
          before(:each) do
            File.stub(:exists?).with(Translation.css_path("es")).and_return(false)
          end
          it "returns an empty array" do
            helper.registrant_css.should == []
          end
        end
        context "with a css file" do
          before(:each) do
            File.stub(:exists?).with(Translation.css_path("es")).and_return(true)
          end
          it "returns the es css file" do
            helper.registrant_css.should == ["locales/es"]
          end
        end
      end
    end
  end

  describe "form helpers" do
    attr_accessor :form
    before(:each) do
      @form = spy(Object)
      partner = Partner.new
      form.stub(:object) { partner }
      form.stub(:text_field) { '<input type="text">' }
      form.stub(:password_field) { '<input type="password">' }
    end

    it "makes a text field by default" do
      html = helper.field_div(form, :name)
      assert_match /input type="text"/, html
    end

    it "uses :kind option to make a different type of field" do
      html = helper.field_div(form, :name, :kind => "password")
      assert_match /input type="password"/, html
    end
  end
end
