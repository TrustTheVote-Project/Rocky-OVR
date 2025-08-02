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

describe Api::V4::RegistrationsController do

  describe 'create' do
    it 'should return URL of PDF to be generated' do
      expect_api_response :pdfurl => "https://example-pdf.com/123.pdf", :uid => "123"
      registrant= double(Registrant)
      registrant.stub(:uid) { "123" }
      registrant.stub(:pdf_download_path) { '/123.pdf' }
      new_registration { registrant  }
    end

    it 'should catch invalid fields' do
      expect_api_error :message => "Error message", :field_name => "invalid_field"
      new_registration { raise V4::RegistrationService::ValidationError.new('invalid_field', 'Error message') }
    end

    it 'should report unsupported language' do
      expect_api_error :message => 'Unsupported language'
      new_registration { raise V4::UnsupportedLanguageError }
    end

    it 'should report invalid parameter type' do
      expect_api_error :message => "Invalid parameter type", :field_name => "attr"
      new_registration { raise(ActiveRecord::UnknownAttributeError.new(Registrant.new, 'attr')) }
    end

    [ 1, 2 ].each do |qnum|
      it "should report error when an answer is provided without a question" do
        expect_api_error :message =>"Question #{qnum} required when Answer #{qnum} provided"
        new_registration { raise(V4::RegistrationService::SurveyQuestionError.new("Question #{qnum} required when Answer #{qnum} provided")) }
      end
    end
  end

  describe 'create_finish_with_state' do
    it 'should render nothing when success' do
      reg = FactoryGirl.create(:step_2_registrant)
      expect_api_response :registrations => reg.to_finish_with_state_array
      new_finish_with_state_registration  { reg }
    end
  end
  
  describe 'create_pa' do
    let(:query) {
      {
        "rocky_request" => {
          "lang" => "en",
          "phone_type" => "home",
          "partner_id" => 1,
          "opt_in_email" => false,
          "opt_in_sms" => false,
          "opt_in_volunteer" => false,
          "partner_opt_in_sms" => true,
          "partner_opt_in_email" => true,
          "partner_opt_in_volunteer" => false,
          "finish_with_state" => true,
          "created_via_api" => true,
          "source_tracking_id" => "Aaron Huttner",
          "partner_tracking_id" => "22201",
          "geo_location" => {
            "lat" => 123,
            "long" => -123
          },
          "open_tracking_id" => "metro canvasing",
          "voter_records_request" => {
            "type" => "registration",
            "generated_date" => "2016-06-16T19:44:45+00:00",
            "voter_registration" => {
              "date_of_birth" => "2016-06-16",
              "mailing_address" => {
                "numbered_thoroughfare_address" => {
                  "complete_address_number" => "\"\"",
                  "complete_street_name" => "801 N. Monroe",
                  "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                  },
                  "complete_place_names" => [
                    {
                      "place_name_type" => "MunicipalJurisdiction",
                      "place_name_value" => "Philadelphia"
                    },
                    {
                      "place_name_type" => "County",
                      "place_name_value" => "Philadelphia"
                    }
                  ],
                  "state" => "Virginia",
                  "zip_code" => "22201"
                }
              },
              "previous_registration_address" => {
                "numbered_thoroughfare_address" => {
                  "complete_address_number" => "\"\"",
                  "complete_street_name" => "801 N. Monroe",
                  "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                  },
                  "complete_place_names" => [
                    {
                      "place_name_type" => "MunicipalJurisdiction",
                      "place_name_value" => "Philadelphia"
                    },
                    {
                      "place_name_type" => "County",
                      "place_name_value" => "Philadelphia"
                    }
                  ],
                  "state" => "Virginia",
                  "zip_code" => "22201"
                }
              },
              "registration_address" => {
                "numbered_thoroughfare_address" => {
                  "complete_address_number" => "\"\"",
                  "complete_street_name" => "801 N. Monroe",
                  "complete_sub_address" => {
                    "sub_address_type" => "APT",
                    "sub_address" => "Apt 306"
                  },
                  "complete_place_names" => [
                    {
                      "place_name_type" => "MunicipalJurisdiction",
                      "place_name_value" => "Philadelphia"
                    },
                    {
                      "place_name_type" => "County",
                      "place_name_value" => "Philadelphia"
                    }
                  ],
                  "state" => "Virginia",
                  "zip_code" => "22201"
                }
              },
              "registration_address_is_mailing_address" => false,
              "name" => {
                "first_name" => "Aaron",
                "last_name" => "Huttner",
                "middle_name" => "Bernard",
                "title_prefix" => "Mr",
                "title_suffix" => "Jr"
              },
              "previous_name" => {
                "first_name" => "Aaron",
                "last_name" => "Huttner",
                "middle_name" => "Bernard",
                "title_prefix" => "Mr",
                "title_suffix" => "Jr"
              },
              "gender" => "male",
              "race" => "American Indian / Alaskan Native",
              "party" => "democratic",
              "voter_classifications" => [
                {
                  "type" => "eighteen_on_election_day",
                  "assertion" => true
                },
                {
                  "type" => "united_states_citizen",
                  "assertion" => true
                },
                {
                  "type" => "send_copy_in_mail",
                  "assertion" => true
                },
                {
                  "type" => "agreed_to_declaration",
                  "assertion" => true
                }
              ],
              "signature" => {
                "mime_type" => "image/png",
                "image" => "?"
              },
              "voter_ids" => [
                {
                  "type" => "drivers_license",
                  "string_value" => "1243asdf",
                  "attest_no_such_id" => false
                }
              ],
              "contact_methods" => [
                {
                  "type" => "phone",
                  "value" => "555-555-5555",
                  "capabilities" => [
                    "voice",
                    "fax",
                    "sms"
                  ]
                }
              ],
              "additional_info" => [
                {
                  "name" => "preferred_language",
                  "string_value" => "english"
                }
              ]
            }
          }
        }
      }
    }
    subject { post :create_pa, params: query, as: 'json' }

    context 'invalid request structure' do
      let(:query) { {} }
      it 'returns error code 200' do
        expect(subject.status).to be_eql(200)
      end
    end

    context 'successful registration' do
      let(:valid_registrant) { FactoryGirl.create(:api_v4_maximal_registrant) }
      before(:each) do
        valid_registrant.state_ovr_data = {}
        allow(V4::RegistrationService).to receive(:create_pa_registrant).and_return(valid_registrant)
        allow(V4::RegistrationService).to receive(:valid_for_pa_submission).and_return([])
        allow(V4::RegistrationService).to receive(:register_with_pa).with(valid_registrant) { |r| r.state_ovr_data["pa_transaction_id"]="APP_ID"}
      end
      it 'should return a 200 response' do
        expect(subject.code).to eql "200"
      end
      it 'should queue the PA registration' do
        expect(valid_registrant).to receive(:save!) 
        mock_delay = double("Delay")
        expect(V4::RegistrationService).to receive(:delay).and_return(mock_delay)
        expect(mock_delay).to receive(:async_register_with_pa).with(valid_registrant.id)
        subject
      end
      
      it 'should return a body with registration_success: true' do
        expect(subject.headers["Content-Type"]).to include "application/json"
        result = JSON.parse(subject.body)
        expect(result).to include({"registration_success" => true})
      end
    end
    context 'registrant record fails rocky validation' do
      let(:invalid_registrant) { double(Registrant, valid?: false, errors: double("Errors", full_messages: ["Message One", "Message Two"])).as_null_object}
      before(:each) do
        allow(V4::RegistrationService).to receive(:create_pa_registrant).and_return(invalid_registrant)
      end
      it 'should return a 200 response' do
        expect(subject.status).to be_eql(200)
      end
      # it 'should return a body with registration_success: false and an error list of all the validation messages' do
      #   resp = JSON.parse(subject.body)
      #   expect(resp["registration_success"]).to eq(true)
      #   expect(resp["errors"]).to eq([
      #     "Message One",
      #     "Message Two"
      #   ])
      # end
    end
    context 'registrant record fails PA validation' do
      let(:valid_registrant) { FactoryGirl.create(:api_v4_maximal_registrant) }
      
      before(:each) do
        allow(V4::RegistrationService).to receive(:create_pa_registrant).and_return(valid_registrant)
        allow(V4::RegistrationService).to receive(:valid_for_pa_submission).and_return(["PA Error One", "PA Error Two"])        
      end
      it 'should return a 200 response' do
        expect(subject.status).to eq(200)
      end
      # it 'should return a body with registration_success: false and an error list of all the validation messages' do
      #   result = JSON.parse(subject.body)
      #   expect(result["registration_success"]).to eq(true)
      #   expect(result["errors"]).to eq([
      #     "PA Error One",
      #     "PA Error Two"
      #   ])
      # end
    end
  end

  describe 'pdf_ready' do
    it "should catch errors" do
      expect_api_error :message => 'error'
      pdf_ready { raise ArgumentError.new('error') }
      
    end
    it "returns a hash of pdfready true/false and uid" do
      expect_api_response({:pdf_ready => true, :UID=>"1234"})
      pdf_ready { true }

      expect_api_response({:pdf_ready => false, :UID=>"1234"})
      pdf_ready { false }
    end
  end

  describe 'stop_reminders' do
    it "should catch errors" do
      expect_api_error :message => 'error'
      stop_reminders { raise ArgumentError.new('error') }
    end
    it "calls the reg service stop_reminders and returns registrant data and whether reminders were stopped" do
      expect_api_response({:reminders_stopped => true, :UID=>"1234", :first_name=>"fn", :last_name=>"ln", :email_address=>"email"})
      stop_reminders do
        {:reminders_stopped => true, :first_name=>"fn", :last_name=>"ln", :email_address=>"email"}
      end
    end
  end

  # describe 'bulk' do
  #   it "should catch errors" do
  #     expect_api_error :message => 'error'
  #     bulk { raise ArgumentError.new('error') }
  #   end
  #   it "calls the reg service bulk_crate and returns list of results" do
  #     expect_api_response({:registrants_added=>[[true],[false,"message"]]})
  #     bulk do
  #       [[true],[false,"message"]]
  #     end
  #   end
  # end


  private

  def pdf_ready(&block)
    query = { :UID=>"1234"}
    V4::RegistrationService.stub(:check_pdf_ready).with(query, &block)
    get :pdf_ready, params: query, :format=>'json'
  end
  
  def stop_reminders(&block)
    query = { :UID=>"1234"}
    V4::RegistrationService.stub(:stop_reminders).with(query, &block)
    post :stop_reminders, params: query, :format=>'json'
  end
  def bulk(&block)
    query = { :registrants=>[], :partner_id=>1, :partner_API_key=>"1"}
    V4::RegistrationService.stub(:bulk_create).with([], 1, "1", &block)
    post :bulk, params: query, :format=>'json'
    
  end
  
  def registrations(&block)
    query = { :partner_id => nil, :partner_api_key => nil, :since => nil, :email=>nil }
    V4::RegistrationService.stub(:find_records).with(query, &block)
    get :index, :as => 'json'
  end
  def gregistrations(&block)
    query = { :gpartner_id => nil, :gpartner_api_key => nil, :since => nil, :email=>nil }
    V4::RegistrationService.stub(:find_records).with(query, &block)
    get :index_gpartner, :as => 'json'
  end

  def new_registration(&block)
    data = {}
    V4::RegistrationService.stub(:create_record).with(data, &block)
    post :create, :as => 'json', params: {:registration => data}
  end

  def new_finish_with_state_registration(&block)
    data = { 'lang' => 'en', 'partner_id' => Partner.first.id }
    V4::RegistrationService.stub(:create_record).with(ActionController::Parameters.new(data).permit!, true, &block)
    post :create_finish_with_state, :as => 'json', params: {:registration => data}
  end

end
