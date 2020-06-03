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
require File.dirname(__FILE__) + '/../rails_helper'

describe Partner do

  before(:each) do
    allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
  end

  describe "creation" do
    it "sets an API key on creation" do
      p = FactoryGirl.create(:partner, :api_key=>'')
      p.api_key.should_not be_blank
    end
  end
  
  describe ".deactivate_stale_partners!" do
    let(:p1) { FactoryGirl.create(:partner, last_login_at: 100.day.ago, current_login_at: nil, updated_at: 1.year.ago) }
    let(:p2) { FactoryGirl.create(:partner, last_login_at: 1.day.ago, current_login_at: nil, updated_at: 1.year.ago) }
    let(:p3) { FactoryGirl.create(:partner, last_login_at: 100.day.ago, current_login_at: nil, updated_at: 1.year.ago) } #login-inactive
    it "finds login-inactive partners without recent registrants and sets active to false" do
      r1 = FactoryGirl.create(:step_1_registrant, partner: p1, created_at: 1.year.ago) #registration-inactive
      r2 = FactoryGirl.create(:step_1_registrant, partner: p2, created_at: 1.day.ago)
      r3 = FactoryGirl.create(:step_1_registrant, partner: p3, created_at: 1.day.ago)
      Partner.deactivate_stale_partners!
      p1.reload
      p2.reload
      p3.reload
      expect(p1.active).to eq(false)
      expect(p2.active).to eq(true)
      expect(p3.active).to eq(true)
    end
    it "email list of deactivated partners to admin" do
      r1 = FactoryGirl.create(:step_1_registrant, partner: p1, created_at: 1.year.ago)
      r2 = FactoryGirl.create(:step_1_registrant, partner: p2, created_at: 1.day.ago)
      expect {
        Partner.deactivate_stale_partners!
      }.to change { ActionMailer::Base.deliveries.count }.by(1)      
    end  
  end

  describe ".inactive" do
    let(:p1) { FactoryGirl.create(:partner, last_login_at: 100.day.ago, updated_at: 1.year.ago) }
    let(:p2) { FactoryGirl.create(:partner, last_login_at: 1.day.ago, updated_at: 1.year.ago) }
    let(:p3) { FactoryGirl.create(:partner, last_login_at: 100.day.ago, updated_at: 1.year.ago) }
    it "returns partners with no recent started registrations and no recent logins" do
      r1 = FactoryGirl.create(:step_1_registrant, partner: p1, created_at: 1.year.ago)
      r2 = FactoryGirl.create(:step_1_registrant, partner: p2, created_at: 1.day.ago)
      r3 = FactoryGirl.create(:step_1_registrant, partner: p3, created_at: 1.day.ago)
      inactive_partner_ids = Partner.inactive.pluck(:id)      
      expect(inactive_partner_ids).to include(p1.id)
      expect(inactive_partner_ids).not_to include(p3.id) # has a recent registration
      expect(inactive_partner_ids).not_to include(p2.id)
    end
  end

  describe "survey questions for non en/es" do
    let(:p) { FactoryGirl.create(:partner) }
    describe "survey_question_1_zh-tw" do
      it "reads from the question_1 hash" do
        p.survey_question_1 = {'zh_tw'=>"question in zh-tw"}
        p.send(:"survey_question_1_zh-tw").should == "question in zh-tw"
      end
      it "returns nil when not present" do
        p.send(:"survey_question_1_zh-tw").should be_nil
      end
    end
    describe "survey_question_1_zh-tw=" do
      it "sets the value without destroying other values" do
        p.survey_question_1 = {'zh_tw'=>"old", 'ko'=>'unchanged'}  
        p.send(:"survey_question_1_zh-tw=",'new')
        p.send(:"survey_question_1_zh-tw").should == 'new'
        p.send(:"survey_question_1_ko").should == 'unchanged'
      end
    end
  end

  describe "#primary?" do
    it "is false for non-primary partner" do
      assert !FactoryGirl.build(:partner).primary?
    end
  end
  
  describe "#generate_api_key!" do
    it "should change the api key" do
      p = FactoryGirl.create(:partner)
      p.api_key.should_not be_blank
      old_key = p.api_key
      p.generate_api_key!
      p.reload
      p.api_key.should_not == old_key
    end
  end
  
  describe "#generate_random_password" do
    it "sets the password and password confirmation" do
      p = FactoryGirl.build(:api_created_partner)
      p.generate_random_password
      p.password.should_not be_blank
      p.password_confirmation.should_not be_blank
    end
  end
  
  describe "#generate_username" do
    it "should set a valid username from email address" do
      p = FactoryGirl.build(:partner)
      p.should be_valid
      p.email.should_not be_blank
      p.username = ''
      p.generate_username
      p.username.should_not be_blank
      p.should be_valid
    end
  end
  describe "#logo_url=(URL)" do
    it "opens the file from the URL when saved" do
      url = "http://s3.amazonaws.com/rocky-assets/assets/rtv-square-reversed.png"
      p = FactoryGirl.build(:partner)
      mock_io = double("StringIO")
      mock_uri = double("URI")
      mock_uri.stub(:path).and_return(url)
      mock_io.stub(:base_uri).and_return(mock_uri)
      p.stub(:open).with(url).and_return(mock_io)
      p.stub(:logo=).with(mock_io)
      p.logo_url = url
      p.save!
      p.should have_received(:open).with(url)
    end
    it "attaches the URL file as the logo" do
      url = "https://s3.amazonaws.com/rocky-assets/assets/rtv-square-reversed.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = url
      p.save!
      p.logo.url.should_not == "/logos/original/missing.png"
    end
    it "adds a validation error if the url is not http" do
      bad_url = "home_rtv_logo_wrong.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = bad_url
      p.should_not be_valid
      p.errors[:logo_image_URL].should include("Please provide an HTTP(s) url")
    end
    it "adds a validation error if the file can not be downloaded" do
      bad_url = "https://www.rockthevote.org/wp-content/uploads/2017/07/RTV_white_updated_wrong.png"
      p = FactoryGirl.build(:partner)
      p.logo_url = bad_url
      p.should_not be_valid
      p.errors[:logo_image_URL].should include("Could not download #{bad_url} for logo")
    end
  end
  
  
  
  describe "#partner_css_download_url=(URL)" do
    it "opens the file from the URL when saved" do
      url = "https://s3.amazonaws.com/rocky-assets/assets/registration2.css"
      p = FactoryGirl.build(:partner)
      mock_io = double("StringIO")
      mock_uri = double("URI")
      mock_uri.stub(:path).and_return(url)
      mock_io.stub(:base_uri).and_return(mock_uri)
      mock_io.stub(:read).and_return("css contents")
      mock_io.stub(:close)
      p.stub(:open).with(url).and_return(mock_io)
      p.stub(:logo=).with(mock_io)
      p.partner_css_download_url = url
      p.save!
      p.should have_received(:open).with(url)
    end
    it "attaches the CSS file as the partner css" do
      url = "http://s3.amazonaws.com/rocky-assets/assets/registration2.css"
      p = FactoryGirl.build(:partner)
      p.partner_css_download_url = url
      p.save!
      p.partner_css_present?.should be_truthy      
    end
    it "adds a validation error if the url is not http" do
      bad_url = "home_rtv_logo_wrong.png"
      p = FactoryGirl.build(:partner)
      p.partner_css_download_url = bad_url
      p.should_not be_valid
      p.errors[:partner_css_download_URL].should include("Please provide an HTTP(s) url")
    end
    it "adds a validation error if the file can not be downloaded" do
      bad_url = "http://www.rockthevote.com/assets/images/structure/home_rtv_logo_wrong.css"
      p = FactoryGirl.build(:partner)
      p.partner_css_download_url = bad_url
      p.should_not be_valid
      p.errors[:partner_css_download_URL].should include("Could not download #{bad_url} for partner css")
    end
  end
  
  
  
  describe "#valid_api_key?(key)" do
    let(:primary) { FactoryGirl.build(:partner, :api_key=>"1234")}
    before(:each) do
      Partner.stub(:primary_partner).and_return(primary)
    end
    it "returns false when blank or not matching" do
      partner = FactoryGirl.build(:partner, :api_key=>"")
      partner.valid_api_key?("").should be_falsey
      partner.api_key="abc"
      partner.valid_api_key?("bca").should be_falsey
    end
    it "return true when matching" do
      partner = FactoryGirl.build(:partner, :api_key=>"abcdef")
      partner.valid_api_key?("abcdef").should be_truthy
    end
    it "returns true when matching the primary partner" do
      partner = FactoryGirl.build(:partner, :api_key=>"abcdef")
      partner.valid_api_key?("1234").should be_truthy
    end
  end

  describe "widget image" do
    it "is set to default value if none set explicitly" do
      partner = FactoryGirl.build(:partner, :widget_image => nil)
      assert partner.valid?
      assert_equal Partner::DEFAULT_WIDGET_IMAGE_NAME, partner.widget_image_name
      partner.widget_image_name = "rtv100x100v1"
      assert partner.valid?
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "gets name of widget image" do
      partner = FactoryGirl.build(:partner, :widget_image => "rtv-100x100-v1.gif")
      assert_equal "rtv100x100v1", partner.widget_image_name
    end

    it "sets widget_image by name" do
      partner = FactoryGirl.build(:partner, :widget_image => nil)
      partner.widget_image_name = "rtv100x100v1"
      assert_equal "rtv-100x100-v1.gif", partner.widget_image
    end
  end

  describe "logo image" do
    it "has an attached logo" do
      partner = FactoryGirl.build(:partner)
      assert partner.respond_to?(:logo)
      assert_equal Paperclip::Attachment, partner.logo.class
    end

    it { should validate_attachment_content_type(:logo).
                    allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg', 'image/x-png').
                    rejecting('text/plain', 'text/xml') }

  end

  describe "custom_logo?" do
    after(:each) do
      FileUtils.rm_rf(Rails.root.join("tmp/system/logos"))
    end

    it "is always false for primary partner" do
      partner = Partner.find(Partner::DEFAULT_ID)
      assert !partner.custom_logo?
      File.open(File.join(fixture_files_path, "partner_logo.jpg"), "r") do |logo|
        partner.update_attributes(:logo => logo)
        assert !partner.custom_logo?
      end
    end

    it "is true for partners with logos" do
      partner = FactoryGirl.build(:partner)
      File.open(File.join(fixture_files_path, "partner_logo.jpg"), "r") do |logo|
        partner.update_attributes(:logo => logo)
        assert partner.custom_logo?
      end
    end

    it "is false for partners without logos" do
      partner = FactoryGirl.build(:partner)
      assert !partner.custom_logo?
    end
  end

  describe "whitelabeling" do
    let(:paf) { double(PartnerAssetsFolder) }
    before(:each) do
      PartnerAssetsFolder.stub(:new).and_return(paf)
      paf.stub(:asset_file).and_return(true)
    end
  
    describe "Class Methods" do
      describe "#add_whitelabel(partner_id, app_css, reg_css)" do
        
        before(:each) do
          @partner = FactoryGirl.create(:partner)
          File.stub(:expand_path).with("app.css").and_return("app.css")
          File.stub(:expand_path).with("reg.css").and_return("reg.css")
          File.stub(:expand_path).with("part.css").and_return("part.css")
          File.stub(:open).with("app.css", "r").and_return("app.css")
          File.stub(:open).with("reg.css", "r").and_return("reg.css")
          File.stub(:open).with("part.css", "r").and_return("part.css")

          Partner.stub(:find).and_return(@partner)
          
          File.stub(:exists?).with("app.css").and_return(true)
          File.stub(:exists?).with("reg.css").and_return(true)
          File.stub(:exists?).with("part.css").and_return(true)
          
          @partner.stub(:any_css_present?).and_return(false)
          @partner.stub(:application_css_present?).and_return(true)
          @partner.stub(:registration_css_present?).and_return(true)
          @partner.stub(:partner_css_present?).and_return(true)


          paf.stub(:update_css)
          
          
        end
        it "finds the partner by id" do
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          Partner.should have_received(:find).with("123")
        end
        it "raises an error message if the partner is the primary one" do
          @partner.stub(:primary?).and_return(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("You can't whitelabel the primary partner.")
        end
        it "raises an error message if the partner is not found" do
          Partner.stub(:find).and_return(nil)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner with id '123' was not found.")
        end
        it "raises an error message with what to do if the partner is already whitelabeled" do
          @partner.stub(:whitelabeled).and_return(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner '123' is already whitelabeled. Try running 'rake partner:upload_assets 123 app.css reg.css'")
        end
        it "raises an error message with what to do if the partner already has assets" do
          @partner.stub(:any_css_present?).and_return(true)
          expect {
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          }.to raise_error("Partner '123' has assets. Try running 'rake partner:enable_whitelabel 123'")
        end
        it "sets the partner as whitelabeled if not already" do
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          Partner.find(@partner.id).should be_whitelabeled
        end

        it "copies the CSS to the partner path (with the correct names) from the filesystem" do
          
          paf.should_receive("update_css").with("application", "app.css")
          paf.should_receive("update_css").with("registration", "reg.css")
          paf.should_receive("update_css").with("partner", "part.css")
          
          Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          
        end
        it "copies the CSS files to the partner path (with the correct names) from URLs" do
          pending "Don't need URL designation of assets yet"
          raise 'not implemented'
        end
        it "does not set the partner as whitelabeled if the path functions fail" do
          @partner.stub(:application_css_present?).and_return(false)
          begin
            Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          rescue
          end
          Partner.find(@partner.id).should_not be_whitelabeled
        end
        it "outputs the partner path on success" do
          output = Partner.add_whitelabel("123", "app.css", "reg.css", "part.css")
          output.should == "Partner '123' has been whitelabeled. Place all asset files in\n#{@partner.assets_path}"
        end
      end
    end

    describe "#from_email_verified?" do
      let(:partner) { FactoryGirl.create(:partner) }
      context "when from_email is blank" do
        before(:each) do
          partner.from_email = nil
        end
        it "returns false" do
          expect(partner.from_email_verified?).to eq(false)
        end
      end
      context "when from email is present" do
        before(:each) do
          partner.from_email = "from@example.com"
        end
        context 'when from email has been verified recently' do
          it "returns true" do
            partner.from_email_verified_at = 59.minutes.ago
            expect(partner.from_email_verified?).to eq(true)
          end          
        end
        context 'from email verification checked less than 5 minutes ago' do
          it "returns false" do
            partner.from_email_verification_checked_at = 4.minutes.ago
            expect(partner.from_email_verified?).to eq(false)
          end
        end
        context "from email verification has not been checked recently" do
          it "returns check_from_email_verification" do
            expect(partner).to receive(:check_from_email_verification) { "verified_or_not"}
            expect(partner.from_email_verified?).to eq("verified_or_not")
          end
        end
      end
    end

    describe "#assets_path" do
      it "returns the s3 key path to the partner directory" do
        partner = FactoryGirl.create(:partner)
        partner.assets_path.should == "partners/#{partner.id}"
      end
    end

    describe "#any_css_present?" do
      it "returns true if the either custom css files is present" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("application.css").and_return(true)
        paf.stub("asset_file_exists?").with("registration.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner2.css").and_return(false)
        partner.any_css_present?.should be_truthy

        paf.stub("asset_file_exists?").with("application.css").and_return(false)
        paf.stub("asset_file_exists?").with("registration.css").and_return(true)
        paf.stub("asset_file_exists?").with("partner.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner2.css").and_return(false)
        partner.any_css_present?.should be_truthy

        paf.stub("asset_file_exists?").with("application.css").and_return(false)
        paf.stub("asset_file_exists?").with("registration.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner.css").and_return(true)
        paf.stub("asset_file_exists?").with("partner2.css").and_return(true)
        partner.any_css_present?.should be_truthy

        paf.stub("asset_file_exists?").with("application.css").and_return(true)
        paf.stub("asset_file_exists?").with("registration.css").and_return(true)
        paf.stub("asset_file_exists?").with("partner.css").and_return(true)
        paf.stub("asset_file_exists?").with("partner2.css").and_return(true)
        partner.any_css_present?.should be_truthy
      end
      it "returns false if all css files are missing" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("application.css").and_return(false)
        paf.stub("asset_file_exists?").with("registration.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner.css").and_return(false)
        paf.stub("asset_file_exists?").with("partner2.css", nil).and_return(false)
        paf.stub("asset_file_exists?").with("partner2mobile.css", nil).and_return(false)

        partner.any_css_present?.should be_falsey
      end
    end

    describe "#application_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("application.css").and_return(true)
        partner.application_css_present?.should be_truthy
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("application.css").and_return(false)
        partner.application_css_present?.should be_falsey
      end
    end
    describe "#registration_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("registration.css").and_return(true)
        partner.registration_css_present?.should be_truthy
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("registration.css").and_return(false)
        partner.registration_css_present?.should be_falsey
      end
    end
    describe "#partner_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("partner.css").and_return(true)
        partner.partner_css_present?.should be_truthy
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("partner.css").and_return(false)
        partner.partner_css_present?.should be_falsey
      end
    end
    describe "#partner2_css_present?" do
      it "returns true when the file exists" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("partner2.css", nil).and_return(true)
        partner.partner2_css_present?.should be_truthy
      end
      it "returns false when the file is missing" do
        partner = FactoryGirl.build(:partner)
        paf.stub("asset_file_exists?").with("partner2.css", nil).and_return(false)
        partner.partner2_css_present?.should be_falsey
      end
    end

    describe "#application_css_url" do
      it "is returns the URL for the custom application css" do
        partner = FactoryGirl.build(:partner)
        paf.should_receive(:asset_url).with("application.css", nil)
        partner.application_css_url
      end
    end
    describe "#registration_css_url" do
      it "is returns the URL for the custom registration css" do
        partner = FactoryGirl.build(:partner)
        paf.should_receive(:asset_url).with("registration.css", nil)
        partner.registration_css_url
      end
    end
    describe "#partner_css_url" do
      it "is returns the URL for the custom partner css" do
        partner = FactoryGirl.build(:partner)
        paf.should_receive(:asset_url).with("partner.css", nil)
        partner.partner_css_url
      end
    end
    describe "#partner2_css_url" do
      it "is returns the URL for the custom partner css" do
        partner = FactoryGirl.build(:partner)
        paf.should_receive(:asset_url).with("partner2.css", nil)
        partner.partner2_css_url
      end
    end
    
    describe "pdf_logos" do
      let(:partner) { FactoryGirl.build(:partner) }
      describe "pdf_logo_present?" do
        context "when pdf_logo_ext is nil" do
          before(:each) do
            partner.stub(:pdf_logo_ext).and_return(nil)
          end
          it "returns false" do
            partner.pdf_logo_present?.should be_falsey
          end
          
        end
        context "when pdf_logo_ext is not nil" do
          before(:each) do
            partner.stub(:pdf_logo_ext).and_return('val')
          end
          it "returns true" do
            partner.pdf_logo_present?.should be_truthy
          end
        end
      end
      describe "pdf_logo_ext" do
        context "when there is no pdf_logo" do
          before(:each) do
            paf.stub(:asset_file).and_return(false)
          end
          it "returns nil" do
            partner.pdf_logo_ext.should be_nil
          end
        end
        context "when there is a pdf_logo jpeg" do
          before(:each) do
            paf.stub(:asset_file).and_return(false)
            paf.stub(:asset_file).with('pdf_logo.jpeg', nil).and_return(true)
          end
          it "returns png" do
            partner.pdf_logo_ext.should == 'jpeg'
          end
        end
      end    
      # describe "pdf_logo_url(ext)" do
      #   context "when nil is passed" do
      #     context "when pdf_logo_ext returns nil" do
      #       before(:each) do
      #         partner.stub(:pdf_logo_ext).and_return(nil)
      #       end
      #       it "returns the asset url with a gif extension" do
      #         partner.pdf_logo_url(nil).should == "#{partner.assets_url}/#{Partner::PDF_LOGO}.gif"
      #       end
      #     end
      #     context "when pdf_logo_ext returns jpg" do
      #       before(:each) do
      #         partner.stub(:pdf_logo_ext).and_return('jpg')
      #       end
      #       it "returns the url with a jpg exention" do
      #         partner.pdf_logo_url(nil).should == "#{partner.assets_url}/#{Partner::PDF_LOGO}.jpg"
      #       end
      #     end
      #   end
      #   context "when a value is passed" do
      #     it "returns the url with the passed exention" do
      #       partner.pdf_logo_url('jpeg').should == "#{partner.assets_url}/#{Partner::PDF_LOGO}.jpeg"
      #     end
      #   end
      # end
      describe "absolute_pdf_logo_path(ext)" do
        before(:each) do
          allow(paf).to receive(:asset_url) {|p| "s3-url/#{p}"}
        end
        context "when nil is passed" do
          context "when pdf_logo_ext returns nil" do
            before(:each) do
              partner.stub(:pdf_logo_ext).and_return(nil)
            end
            it "returns the path with a gif extension" do
              partner.absolute_pdf_logo_path.should == "s3-url/#{Partner::PDF_LOGO}.gif"
            end
          end
          context "when pdf_logo_ext returns jpg" do
            before(:each) do
              partner.stub(:pdf_logo_ext).and_return('jpg')
            end
            it "returns the path with a jpg exention" do
              partner.absolute_pdf_logo_path.should == "s3-url/#{Partner::PDF_LOGO}.jpg"
            end
          end
        end
      end
    end
    
    describe "registration_instructions_url" do
      let(:partner) { FactoryGirl.build(:partner) }
      it "can be blank" do
        partner.registration_instructions_url = ''
        partner.should be_valid
      end
      it "must include <STATE> and <LOCALE>" do
        partner.registration_instructions_url = 'http://test.com/<state>-<locale>'
        partner.should_not be_valid
        partner.errors_on(:registration_instructions_url).should have(2).errors

        partner.registration_instructions_url = 'http://test.com/'
        partner.should_not be_valid
        partner.errors_on(:registration_instructions_url).should have(2).errors

        partner.registration_instructions_url = 'http://test.com/<STATE>-<locale>'
        partner.should_not be_valid
        partner.errors_on(:registration_instructions_url).should have(1).errors

        partner.registration_instructions_url = 'http://test.com/<STATE>-<LOCALE>'
        partner.should be_valid
      end
      
      it "must be a valid url format" do
        partner.registration_instructions_url = 'abccom/<STATE>-<LOCALE>'
        partner.should_not be_valid

        partner.registration_instructions_url = 'abc.com/<STATE>-<LOCALE>'
        partner.should_not be_valid
        
        partner.registration_instructions_url = 'http://b.c/<STATE>-<LOCALE>'
        partner.should_not be_valid
        
        partner.registration_instructions_url = 'https://abc.com/<STATE>-<LOCALE>'
        partner.should be_valid
        
        partner.registration_instructions_url = 'http://abc.com/<STATE>-<LOCALE>'
        partner.should be_valid
      end
    end
  end

  describe 'whitelableing fake integration' do

    before(:each) do
      @partner = FactoryGirl.create(:partner)
    end

    it 'reads partner\'s s3 application.css file' do
      fs3 = PartnerFakeS3.wrap(@partner, ['application.css', 'preview/application.css'])
      allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(fs3)

      expect(@partner.application_css_url).to be_eql(fs3.files[0].public_url)
      expect(@partner.application_css_url(:preview)).to be_eql(fs3.files[1].public_url)
      expect(@partner.registration_css_url).to be_eql(nil)
      expect(@partner.registration_css_url(:preview)).to be_eql(nil)
      expect(@partner.partner_css_url).to be_eql(nil)
      expect(@partner.partner_css_url(:preview)).to be_eql(nil)
    end

  end

  describe 'status preview status' do
    before(:each) do
      @partner = FactoryGirl.create(:partner)
    end

    context 'empty assets' do
      it 'not set' do
        allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
        expect(@partner.preview_assets_status).to be_eql(:not_set)
      end
    end

    context 'only preview assets' do
      it 'updated' do
        fs3 = PartnerFakeS3.wrap(@partner, ['preview/application.css', 'preview/somthing.jpg'])
        allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(fs3)
        expect(@partner.preview_assets_status).to be_eql(:updated)
      end
    end


    context 'the same preview and root assets' do
      it 'not_changed' do
        allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
        @partner.folder.write_asset('application.css', 'c1')
        @partner.folder.write_asset('something.jpg', 'c2')
        @partner.folder.write_asset('application.css', 'c1', :preview)
        @partner.folder.write_asset('something.jpg', 'c2', :preview)

        expect(@partner.preview_assets_status).to be_eql(:not_changed) end
    end

    context 'updated preview content' do
      it 'not_changed' do
        allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
        @partner.folder.write_asset('application.css', 'c1')
        @partner.folder.write_asset('something.jpg', 'c2')
        @partner.folder.write_asset('application.css', 'c1', :preview)
        @partner.folder.write_asset('something.jpg', 'c3', :preview)

        expect(@partner.preview_assets_status).to be_eql(:updated) end
    end

  end

  describe "default opt-in sets" do
    it "should be true for RTV and false for partners" do
      partner = Partner.new
      partner.rtv_email_opt_in.should be_truthy
      partner.partner_email_opt_in.should be_falsey
      partner.rtv_sms_opt_in.should be_truthy
      partner.partner_sms_opt_in.should be_falsey
      partner.ask_for_volunteers.should be_falsey
      partner.partner_ask_for_volunteers.should be_falsey
    end
  end

  describe "CSV" do
    let(:partner) { FactoryGirl.create(:partner) }
    # TODO test report generation
    it "can generate CSV of all registrants"
    
    it "can generate CSV for registrants within a time span"
    # registrants = []
    # 3.times {|i| registrants << FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at=> i.months.ago) }
    # registrants << FactoryGirl.create(:step_1_registrant, :partner => partner, :created_at=> 3.months.ago)

  end

  describe "registration statistics" do
    describe "by state" do
      it "should tally registrants by state" do
        partner = FactoryGirl.create(:partner)
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "uses completed/step_5 registrations with or without finish-with-state for stats" do
        partner = FactoryGirl.create(:partner)
        # Assume any relevant states are *allowed* to have online reg
        GeoState.stub(:states_with_online_registration).and_return(['PA','MA','FL','CA'])
        
        # Florida
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = FactoryGirl.create(:step_4_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        
        # California
        2.times do
          reg = FactoryGirl.create(:step_5_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "94101", :party => "Decline to State")
        end

        # Florida
        2.times do 
          reg = FactoryGirl.create(:step_5_registrant, :partner=>partner, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes!(:home_zip_code => "32001", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 5, stats[0][:registrations_count]
        assert_equal 5/7.0, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 2/7.0, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        3.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => other_partner)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by race" do
      it "should tally registrants by race" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'en')) }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal I18n.t('txt.registration.races.hispanic', locale: 'en'), stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should treat race names in different languages as equivalent" do
        partner = FactoryGirl.create(:partner)
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'es'), :locale => "es") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'en')) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'es'), :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal I18n.t('txt.registration.races.hispanic', locale: 'en'), stats[0][:race]
        assert_equal 6, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 4, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "doesn't need both English and Spanish results" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'es'), :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal I18n.t('txt.registration.races.hispanic', locale: 'en'), stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "when the race is blank it is called 'Unknown'" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => "") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'en')) }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Unknown", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:step_5_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'en')) }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal I18n.t('txt.registration.races.hispanic', locale: 'en'), stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :race => I18n.t('txt.registration.races.hispanic', locale: 'en')) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :race => I18n.t('txt.registration.races.mutli_racial', locale: 'en')) }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal I18n.t('txt.registration.races.hispanic', locale: 'en'), stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal I18n.t('txt.registration.races.mutli_racial', locale: 'en'), stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by gender" do
      it "should tally registrants by gender based on name_title" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        stats = partner.registration_stats_gender
        assert_equal 3, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should treat titles in different languages as equivalent" do
        partner = FactoryGirl.create(:partner)
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sr.") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 3, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 6, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 4, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "doesn't need both English and Spanish results" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 3, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:step_5_registrant, :partner => partner, :name_title => "Sra.") }
        stats = partner.registration_stats_gender
        assert_equal 3, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Mr.") }
        3.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :name_title => "Mr.") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :name_title => "Ms.") }
        stats = partner.registration_stats_gender
        assert_equal 3, stats.length
        assert_equal "Male", stats[0][:gender]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Female", stats[1][:gender]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by registration date" do
      it "should tally registrants by date bucket and PDF download state" do
        
        # this puts the 2 months in the "within past year" but not "year to date" category
        new_time = Time.local(2008, 2, 1, 12, 0, 0)
        Timecop.freeze(new_time)
        
        partner = FactoryGirl.create(:partner)
        7.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, pdf_downloaded: true) }

        3.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago, pdf_downloaded: true) }

        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago, pdf_downloaded: true) }

        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago, pdf_downloaded: true) }
        
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.years.ago) }

        stats = partner.registration_stats_completion_date
        
        Timecop.return
        
        assert_equal  8, stats[:day_count][:completed]
        assert_equal  1, stats[:day_count][:downloaded]

        assert_equal 13, stats[:week_count][:completed]
        assert_equal 3, stats[:week_count][:downloaded]

        assert_equal 17, stats[:month_count][:completed]
        assert_equal 5, stats[:month_count][:downloaded]

        assert_equal 17, stats[:year_to_date_count][:completed]
        assert_equal 5, stats[:year_to_date_count][:downloaded]

        assert_equal 19, stats[:year_count][:completed]
        assert_equal 6, stats[:year_count][:downloaded]

        assert_equal 20, stats[:total_count][:completed]
        assert_equal 6, stats[:total_count][:downloaded]
      end

      it "only uses completed/step_5 registrations with or without finish_with_state for stats" do
        partner = FactoryGirl.create(:partner)
        GeoState.stub(:states_with_online_registration).and_return(['PA','MA'])
        
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal  18, stats[:day_count][:completed]
      end

      it "should show percent complete" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago) }
        stats = partner.registration_stats_completion_date
        assert_equal 0.5, stats[:percent_complete][:completed]
      end

      it "should not include :initial state registrants in calculations" do
        partner = FactoryGirl.create(:partner)
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago) }
        5.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago) }
        5.times { FactoryGirl.create(:step_1_registrant,  :partner => partner, :created_at => 2.days.ago, :status => :initial) }
        stats = partner.registration_stats_completion_date
        assert_equal   5, stats[:week_count][:completed]
        assert_equal 0.5, stats[:percent_complete][:completed]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago)
        FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago)
        FactoryGirl.create(:maximal_registrant, :partner => other_partner, :created_at => 2.days.ago)
        stats = partner.registration_stats_completion_date
        assert_equal   1, stats[:week_count][:completed]
        assert_equal 0.5, stats[:percent_complete][:completed]
      end
    end

    describe "finish-with-state by registration date & state" do
      it "should tally registrants by state and date bucket" do
        partner = FactoryGirl.create(:partner)
        GeoState.stub(:states_with_online_registration).and_return(['MA','PA','CA','FL'])
        8.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        5.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")
        end
        4.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.weeks.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")
        end
        2.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.months.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes!(:home_zip_code => "94101", :party => "Decline to State")          
        end
        1.times do
          reg = FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.years.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
          reg.update_attributes(:home_zip_code => "32001", :party => "Decline to State")          
        end
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal "California", stats[0][:state_name]
        assert_equal  8, stats[1][:day_count]
        assert_equal 5, stats[0][:week_count]
        assert_equal 12, stats[1][:month_count]
        assert_equal 7, stats[0][:year_count]
        assert_equal 13, stats[1][:total_count]
      end

      it "only uses completed registrations with finish_with_state for stats" do
        partner = FactoryGirl.create(:partner)
        GeoState.stub(:states_with_online_registration).and_return(['MA','PA'])
        
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago) }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        8.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :created_at => 2.hours.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false) }
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal  "Massachusetts", stats[0][:state_name]
        assert_equal  8, stats[0][:day_count]
        assert_equal  1, stats.size
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        GeoState.stub(:states_with_online_registration).and_return(['MA','PA'])
        
        other_partner = FactoryGirl.create(:partner)
        FactoryGirl.create(:maximal_registrant, :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        FactoryGirl.create(:step_4_registrant,  :partner => partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        FactoryGirl.create(:maximal_registrant, :partner => other_partner, :created_at => 2.days.ago, :finish_with_state=>true, :send_confirmation_reminder_emails=>false)
        stats = partner.registration_stats_finish_with_state_completion_date
        assert_equal  "Massachusetts", stats[0][:state_name]
        assert_equal   1, stats[0][:week_count]
        assert_equal  1, stats.size
      end
    end


    describe "by age" do
      it "should tally registrants count and percentage by age bracket on updated_at date" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }
        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
        assert_equal  0.40, stats[:age_under_18][:percentage]
        assert_equal  0.25, stats[:age_18_to_29][:percentage]
        assert_equal  0.20, stats[:age_30_to_39][:percentage]
        assert_equal  0.10, stats[:age_40_to_64][:percentage]
        assert_equal  0.05, stats[:age_65_and_up][:percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { FactoryGirl.create(:under_18_finished_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        8.times { FactoryGirl.create(:step_1_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_2_registrant, :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:step_3_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:step_4_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }

        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        8.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 17.years.ago.strftime("%m/%d/%Y")) }
        5.times { FactoryGirl.create(:step_5_registrant,  :partner => other_partner, :date_of_birth => 21.years.ago.strftime("%m/%d/%Y")) }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 31.years.ago.strftime("%m/%d/%Y")) }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 41.years.ago.strftime("%m/%d/%Y")) }
        1.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :date_of_birth => 71.years.ago.strftime("%m/%d/%Y")) }

        stats = partner.registration_stats_age
        assert_equal  8, stats[:age_under_18][:count]
        assert_equal  5, stats[:age_18_to_29][:count]
        assert_equal  4, stats[:age_30_to_39][:count]
        assert_equal  2, stats[:age_40_to_64][:count]
        assert_equal  1, stats[:age_65_and_up][:count]
      end
    end

    describe "by party" do
      it "should tally registrants by party" do
        partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94114", :party => "Decline to State") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "counts states that do not require party as 'None'" do
        partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "02134") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        assert_equal({:count => 8, :percentage => 0.40, :party => "None"},        stats[0])
        assert_equal({:count => 5, :percentage => 0.25, :party => "Other"},       stats[1])
        assert_equal({:count => 4, :percentage => 0.20, :party => "Republican"},  stats[2])
        assert_equal({:count => 2, :percentage => 0.10, :party => "Green"},       stats[3])
        assert_equal({:count => 1, :percentage => 0.05, :party => "Democratic"},  stats[4])
      end

      it "should only include data for this partner" do
        partner = FactoryGirl.create(:partner)
        other_partner = FactoryGirl.create(:partner)
        1.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Democratic") }
        2.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Green") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => partner, :home_zip_code => "94103", :party => "Decline to State") }
        4.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Republican") }
        5.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Other") }
        8.times { FactoryGirl.create(:maximal_registrant, :partner => other_partner, :home_zip_code => "94103", :party => "Decline to State") }
        stats = partner.registration_stats_party
        assert_equal 5, stats.length
        stats.should include({:count => 8, :percentage => 0.4, :party => "None"})
        stats.should include({:count => 5, :percentage => 0.25, :party => "Other"})
        stats.should include({:count => 4, :percentage => 0.20, :party => "Republican"})
        stats.should include({:count => 2, :percentage => 0.10, :party => "Green"})
        stats.should include({:count => 1, :percentage => 0.05, :party => "Democratic"})
      end
    end
  end

  describe 'pixel tracking' do
    let(:p) { Partner.new }
    describe "each email type has a pixel tracking code" do
      EmailTemplate::EMAIL_TYPES.each do |et|
        it "has a getter/setter for #{et}_pixel_tracking_code" do
          p.send("#{et}_pixel_tracking_code=", "#{et} code for pixel tracking")
          expect(p.send("#{et}_pixel_tracking_code")).to eq("#{et} code for pixel tracking")
        end
      end
    end
    
    describe 'default_pixel_tracking_code' do
      it "returns the standard code with email types substituted in" do
        p.default_pixel_tracking_code('abc').should == "<img src=\"http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=<%= @registrant.uid %>&t=event&ec=email&ea=abc_open&el=<%= @registrant.partner_id %>&cs=reminder&cm=email&cn=ovr_email_opens&cm1=1&ul=<%= @registrant.locale %>\" />"
        p.default_pixel_tracking_code('confirmation').should == "<img src=\"http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=<%= @registrant.uid %>&t=event&ec=email&ea=confirmation_open&el=<%= @registrant.partner_id %>&cs=reminder&cm=email&cn=ovr_email_opens&cm1=1&ul=<%= @registrant.locale %>\" />"
        p.default_pixel_tracking_code('chaser').should == "<img src=\"http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=<%= @registrant.uid %>&t=event&ec=email&ea=chase_open&el=<%= @registrant.partner_id %>&cs=reminder&cm=email&cn=ovr_email_opens&cm1=1&ul=<%= @registrant.locale %>\" />"
        p.default_pixel_tracking_code('thank_you_external').should == "<img src=\"http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=<%= @registrant.uid %>&t=event&ec=email&ea=state_integrated_open&el=<%= @registrant.partner_id %>&cs=reminder&cm=email&cn=ovr_email_opens&cm1=1&ul=<%= @registrant.locale %>\" />"
      end
    end
    
  end

  describe "Government Partners" do
    describe "Class Methods" do
      describe ".find_by_login(login)" do
        it "returns nil if the found partner is a government partner" do
          FactoryGirl.create(:partner, :is_government_partner=>false, :username=>"partner")
          FactoryGirl.create(:partner, :is_government_partner=>true, :username=>"gov_partner", :government_partner_zip_code_list=>"90000")
          
          Partner.find_by_login("partner").should be_a(Partner)
          Partner.find_by_login("gov_partner").should be_nil
          
        end
      end
      describe ".government" do
        it "returns all government partners" do
          3.times do
            FactoryGirl.create(:partner)
          end
          gps = []
          3.times do
            gps << FactoryGirl.create(:government_partner, :is_government_partner=>true)
          end
          results = Partner.government
          results.should have(3).partners
          gps.each do |gp|
            results.should include(gp)
          end
        end
      end
      describe ".standard" do
        it "returns all standard partners" do
          ngps = []
          existing_partner_count = Partner.count
          3.times do
            ngps << FactoryGirl.create(:partner)
          end
          gps = []
          3.times do
            gps << FactoryGirl.create(:government_partner, :is_government_partner=>true)
          end
          results = Partner.standard
          results.should have(3 + existing_partner_count).partners
          ngps.each do |gp|
            results.should include(gp)
          end
        end
      end
    end
    
    describe "Validations" do
      it "adds an error to government_partner_state_abbrev and government_partner_zip_code_list when both are blank" do
        p = FactoryGirl.create(:government_partner)
        p.government_partner_zip_codes = nil
        p.government_partner_state_id = nil
        p.valid?.should be_falsey
        p.errors[:government_partner_state_abbrev].should_not be_empty
        p.errors[:government_partner_zip_code_list].should_not be_empty
      end
      it "ads an error to government_partner_state_abbrev and government_partner_zip_code_list when both are present" do
        p = FactoryGirl.create(:government_partner)
        p.government_partner_state_abbrev="MA"
        p.government_partner_zip_code_list="90000"
        p.valid?.should be_falsey
        p.errors[:government_partner_state_abbrev].should_not be_empty
        p.errors[:government_partner_zip_code_list].should_not be_empty
      end
    end
    
    describe "#government_partner_state_abbrev" do
      it "returns the abbreviation for the government_partner_state" do
        p = Partner.new
        p.government_partner_state = GeoState['MA']
        p.government_partner_state_abbrev.should == 'MA'
      end
    end
    describe "#government_partner_state_abbrev=" do
      it "sets the government_partner_state by abbreviation" do
        p = Partner.new
        p.government_partner_state_abbrev= 'MA'        
        p.government_partner_state.should == GeoState['MA']
      end
    end
    describe "#government_partner_zip_code_list" do
      it "returns a new-line separated version of government_partner_zip_codes" do
        p= Partner.new
        p.government_partner_zip_codes = ["12345", "23413-4422", "23415"]
        p.government_partner_zip_code_list.should == ["12345", "23413-4422", "23415"].join("\n")
      end
      it "returns nil when the government_partner_zip_codes is nil" do
        p= Partner.new
        p.government_partner_zip_code_list.should be_nil        
      end
    end
    describe "#government_partner_zip_code_list=" do
      it "cleans a string and sets the government_partner_zip_code_list array" do
        p= Partner.new
        [
          ["242 23423, 23111-342, 23123-1234 4 afe3 235sgsg a3425\n34533 . \\ \n  ef 34335, 34555-1551", ["23423", "23123-1234", "34533", "34335", "34555-1551"]],
          ["12345\n23456\n34567", ["12345", "23456", "34567"]],
          ["22345,23456, 34567", ["22345", "23456", "34567"]],
          ["32345 23456 34567", ["32345", "23456", "34567"]]
        ].each do |string, arr|
            p.government_partner_zip_code_list = string
            p.government_partner_zip_codes.should == arr
            # p.government_partner_zip_code_list = "242 23423, 23111-342, 23123-1234 4 afe3 235sgsg a3425\n34533 . \\ \n  ef 34335, 34555-1551"
            # p.government_partner_zip_codes.should == ["23423", "23123-1234", "34533", "34335", "34555-1551"]
          end
      end
    end
  end
  
  describe "custom_data" do
    it "includes canvassing timeout length" do
      p = Partner.new
      expect(p.custom_data["canvassing_session_timeout_length"]).to eq(RockyConf.ovr_states.PA.api_settings.canvassing_session_timeout_minutes)
    end
    it "includes canvassing validation timeout length" do
      p = Partner.new
      expect(p.custom_data["canvassing_validation_timeout_length"]).to eq(RockyConf.ovr_states.PA.api_settings.canvassing_validation_timeout_minutes)
    end
  end
  

end

