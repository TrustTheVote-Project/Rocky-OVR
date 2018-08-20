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
require File.expand_path(File.dirname(__FILE__) + '/../../rails_helper')

describe V3::RegistrationService do

  describe 'create_record' do
    it 'should raise an error if the language is unknown' do
      lambda { V3::RegistrationService.create_record(:lang => 'unknown') }.should raise_error V3::UnsupportedLanguageError
    end

    it 'should raise an error if the field is unknown' do
      begin
        V3::RegistrationService.create_record(:lang => 'en', :unknown => 'field')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == "unknown attribute 'unknown' for Registrant."
      end
    end

    it 'should not know state_id_number field' do
      begin
        V3::RegistrationService.create_record(:lang => 'en', :state_id_number => '1234')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == "unknown attribute 'state_id_number' for NilClass."
      end
    end

    it 'should raise validation errors when the record is invalid' do
      begin
        V3::RegistrationService.create_record(:lang => 'en')
        fail 'ValidationError is expected'
      rescue V3::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'date_of_birth'
        e.message.should  == "Required"
      end
    end

    it 'should raise an error if the language is unknown even if everything else is bad' do
      lambda {
        V3::RegistrationService.create_record(:lang => 'ex', :home_state_id => 1)
      }.should raise_error V3::UnsupportedLanguageError
    end

    it 'should raise an error if the language is not given' do
      begin
        V3::RegistrationService.create_record(:home_state_id => 'NY')
        fail 'ValidationError is expected'
      rescue V3::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'lang'
        e.message.should  == 'Required'
      end
    end

    [1,2].each do |qnum|
      it "should raise an error if answer #{qnum} is provided without question #{qnum}" do
        begin
          V3::RegistrationService.create_record("survey_answer_#{qnum}" => 'An Answer')
          fail 'SurveyQuestionError is expected'
        rescue V3::RegistrationService::SurveyQuestionError => e
          e.message.should == "Question #{qnum} required when Answer #{qnum} provided"
        end
      end
    end
    [1,2].each do |qnum|
      it "should not raise an error if answer #{qnum} is provided with question #{qnum}" do
        begin
          V3::RegistrationService.create_record("survey_answer_#{qnum}" => 'An Answer', "survey_question_#{qnum}"=>"A Question")
        rescue V3::RegistrationService::SurveyQuestionError => e
          fail 'SurveyQuestionError is not expected'
        rescue
        end
      end
    end

    it 'should deal with states passed as strings' do
      V3::RegistrationService.data_to_attrs({
        :mailing_state => "", :home_state => "1", :prev_state => "AL"
      }).should == {
        :mailing_state_id => nil,
        :home_state_id => nil,
        :prev_state_id => 1,
      }
    end

    context 'complete record' do
      before(:each) do
        @reg = FactoryGirl.create(:api_v3_maximal_registrant, :status => 'step_5')
        @reg.stub(:enqueue_complete_registration_via_api)
        Registrant.stub(:build_from_api_data).with({}, false) { @reg }
      end
      
      describe "async setting" do
        it "should pass async to build_from_api data" do
          @reg.should_receive(:enqueue_complete_registration_via_api).with(true)
          V3::RegistrationService.create_record({async: true}).should

          @reg.should_receive(:enqueue_complete_registration_via_api).with(false)
          V3::RegistrationService.create_record({async: false}).should
        end
        it "should default to true" do
          @reg.should_receive(:enqueue_complete_registration_via_api).with(true)
          V3::RegistrationService.create_record({}).should
        end
      end
      it 'should save the record and generate PDF' do
        V3::RegistrationService.create_record({}).should
      end
    end
  end

  describe 'create_record_finish_with_state' do
    it 'should save the record' do
      reg = V3::RegistrationService.create_record({
        # Lang is supposed to be required?
        :lang                              => 'en',
        :partner_id                        => 0,
        :send_confirmation_reminder_emails => '1',
        :date_of_birth                     => '10-24-1975',
        :email_address                     => 'my@address.com',
        :home_zip_code                     => '02110',
        :us_citizen                        => '1',
        :name_title                        => 'Mr.',
        :last_name                         => 'Smith'
      }, true)

      reg.id.should be
    end
  end

  describe "grommet requests" do
    let(:json_request) {
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
          "partner_opt_in_volunteer" => true,
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
            "canvasser_name" => "Canvasser Name",
            "voter_registration" => {
              "date_of_birth" => "2016-06-16",
              "mailing_address" => {
                "numbered_thoroughfare_address" => {
                  "complete_address_number" => "",
                  "complete_street_name" => "801 N. Monroe",
                  "complete_sub_address" => [{
                    "sub_address_type" => "UNI",
                    "sub_address" => "F"
                  }, {
                    "sub_address_type" => "LINE2",
                    "sub_address" => "C/O Steve"                    
                  }],
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
                  "complete_address_number" => "",
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
                  "complete_address_number" => "",
                  "complete_street_name" => "801 N. Monroe",
                  "complete_sub_address" => [{
                    "sub_address_type" => "APT",
                    "sub_address" => "306"
                  }],
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
                "first_name" => "Aron",
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
                },
                {
                  "type" => "ssn4",
                  "string_value" => "",
                  "attest_no_such_id" => true                  
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
    describe 'create_pa_registrant' do

      it 'builds a finish-with-state rocky registrant instance from the params' do
        r = V3::RegistrationService.create_pa_registrant(json_request["rocky_request"])
        expect(r.valid?).to eq(true)
        expect(r.finish_with_state).to eq(true)
        expect(r.partner_volunteer).to eq(true)
        expect(r.home_address).to eq("801 N. Monroe")
        expect(r.home_unit).to eq("APARTMENT 306")
        expect(r.home_city).to eq("Philadelphia")
        expect(r.home_state_abbrev).to eq("VA")
        expect(r.home_zip_code).to eq("22201")

        expect(r.mailing_address).to eq("801 N. Monroe\nC/O Steve")
        expect(r.mailing_unit).to eq("UNIT F")

        expect(r.prev_address).to eq("801 N. Monroe")
        expect(r.prev_unit).to eq("APARTMENT Apt 306")
      
        expect(r.prev_first_name).to eq("Aron")
        expect(r.first_name).to eq("Aaron")
        expect(r.change_of_name).to be(true)
        expect(r.state_id_number).to eq("1243ASDF")
        expect(r.has_ssn).to be(false)
        expect(r.has_state_license).to be(true)
      
      end
    
      it 'puts the voter_records_request hash, geo_location and open_tracking_id into registrant state_ovr_data' do
        r = V3::RegistrationService.create_pa_registrant(json_request["rocky_request"])
        expect(r.state_ovr_data["voter_records_request"]).to eq(json_request["rocky_request"]["voter_records_request"])
        expect(r.state_ovr_data["geo_location"]).to eq(json_request["rocky_request"]["geo_location"])
        expect(r.open_tracking_id).to eq(json_request["rocky_request"]["open_tracking_id"])
      end
      it "allows a canvasser_name field in the \"voter_records_request\" field" do
        r = V3::RegistrationService.create_pa_registrant(json_request["rocky_request"])
        expect(r.state_ovr_data["voter_records_request"]["canvasser_name"]).to eq("Canvasser Name")
        
      end
    end
  
    describe 'valid_for_pa_submission(registrant)' do
      let(:state_ovr_data) { double(Hash) }
      let(:registrant) { double(Registrant) }
      let(:pa_adapter) { double(VRToPA) }
      before(:each) do
        allow(state_ovr_data).to receive(:[]) { "hash" }
        allow(registrant).to receive(:state_ovr_data) { state_ovr_data }
        allow(VRToPA).to receive(:new).with("hash") { pa_adapter }
        allow(pa_adapter).to receive(:convert)
      end
      subject { V3::RegistrationService.valid_for_pa_submission(registrant) }
      it "initiates a VRToPA conversion" do
        expect(VRToPA).to receive(:new).with("hash") { pa_adapter }
        expect(subject).to eq([])
      end
      it "captures conversion errors and returns an error array" do
        allow(pa_adapter).to receive(:convert) { raise "a" }
        expect(subject).to eq(["Error parsing request: a"])
      end
    end
  
    describe 'register_with_pa(registrant)' do
      it "buils a PA adapter and converts is"
      it "submits a PARegistrationRequest"
      it "saves any errors to the registrant"
      it "raises the error if it's a retry error type"
      it "resubmits w/out signature if it's a signature contrast error"
      it "saves an error and sends admin email if there is no error message or transaction id"      
      it "saves the transaction ID into registrant.state_ovr_data['pa_transaction_id']"
      it "commits the rocky registrant to the DB"
      
      describe "invalid signature VR_WAPI_Invalidsignaturecontrast" do
        let(:r) { V3::RegistrationService.create_pa_registrant(json_request["rocky_request"]) }
        before(:each) do
          allow(PARegistrationRequest).to receive(:send_request).and_return({:error=>"VR_WAPI_Invalidsignaturecontrast"})
        end
        context "when there's a DL" do
          before(:each) do
            json_request["rocky_request"]["voter_records_request"]["voter_registration"]["voter_ids"] = [
                  {
                    "type" => "drivers_license",
                    "string_value" => "12378945",
                    "attest_no_such_id" => false
                  },
                  {
                    "type" => "ssn4",
                    "string_value" => "",
                    "attest_no_such_id" => true                  
                  }
                ]
          end
          it "raises an error and removes the signature if there's a DL" do
            expect(r.state_ovr_data["voter_records_request"]["voter_registration"]["signature"]).to_not be_nil
            expect {
              V3::RegistrationService.register_with_pa(r)
            }.to raise_error("registrant has bad sig, removing and resubmitting")
            expect(r.state_ovr_data["voter_records_request"]["voter_registration"]["signature"]).to be_nil
        
          end
        end
        context "when there's no DL" do
          before(:each) do
            json_request["rocky_request"]["voter_records_request"]["voter_registration"]["voter_ids"] = [
                  {
                    "type" => "drivers_license",
                    "string_value" => "",
                    "attest_no_such_id" => true
                  },
                  {
                    "type" => "ssn4",
                    "string_value" => "",
                    "attest_no_such_id" => true                  
                  }
                ]
          end
          it "also raises an error if there's no DL" do
            expect(r.state_ovr_data["voter_records_request"]["voter_registration"]["signature"]).to_not be_nil
            expect {
              V3::RegistrationService.register_with_pa(r)
            }.to raise_error("registrant has bad sig, removing and resubmitting")
            expect(r.state_ovr_data["voter_records_request"]["voter_registration"]["signature"]).to be_nil
        
          end
        end
      end
    end
    
    describe "track_clock_in_event" do
      let(:data) {{
        "source_tracking_id" => "123457689",
        "partner_tracking_id" => "22201",
        "geo_location" => {
          lat: 123.00, 
          long: -123.00
        },
        "open_tracking_id" => "some text",
        "canvasser_name" => "A Name",
        "device_id"=>"xyz123",
        "clock_in_datetime" => "2016-06-16T19:44:45+00:00",
        "session_timeout_length" => 210
      }}
      # it "raises an error if fields are missing" do
      #   bad_data = data
      #   bad_data.delete(:open_tracking_id)
      #   expect {
      #     V3::RegistrationService.track_clock_in_event(data)
      #   }.to raise_error(V3::RegistrationService::ValidationError)
      # end
      it "should create a new TrackingEvent" do
        expect {
          V3::RegistrationService.track_clock_in_event(data)
        }.to change {
          TrackingEvent.count
        }.by(1)
      end  
      it "creates a new tracking event via open data plus the event name" do
        expect(TrackingEvent).to receive(:create_from_data).with(data.merge(tracking_event_name: "pa_canvassing_clock_in"))
        V3::RegistrationService.track_clock_in_event(data)
      end
      it "stores the data we expect" do
        V3::RegistrationService.track_clock_in_event(data)
        te = TrackingEvent.last
        expect(te.tracking_event_name).to eq("pa_canvassing_clock_in")
        expect(te.source_tracking_id).to eq("123457689")
        expect(te.partner_tracking_id).to eq("22201")
        expect(te.geo_location).to eq({
          "lat" => 123.00, 
          "long" => -123.00
        })
        expect(te.open_tracking_id).to eq("some text")
        expect(te.tracking_data).to eq({
          "canvasser_name" => "A Name",
          "device_id"=>"xyz123",          
          "clock_in_datetime" => "2016-06-16T19:44:45+00:00",
          "session_timeout_length" => 210          
        })
      end
    end
    
  end
  
  describe "track_clock_out_event" do
    let(:data) {{
      "source_tracking_id" => "123457689",
      "partner_tracking_id" => "22201",
      "geo_location" => {
        lat: 123.00, 
        long: -123.00
      },
      "open_tracking_id" => "some text",
      "canvasser_name" => "A Name",
      "abandoned_registrations" => 3,
      "completed_registrations" => 7,
      "clock_out_datetime" => "2016-06-16T19:44:45+00:00",      
    }}
    it "should create a new TrackingEvent" do
      expect {
        V3::RegistrationService.track_clock_out_event(data)
      }.to change {
        TrackingEvent.count
      }.by(1)
    end  
    it "creates a new tracking event via open data" do
      expect(TrackingEvent).to receive(:create_from_data).with(data.merge(tracking_event_name: "pa_canvassing_clock_out"))
      V3::RegistrationService.track_clock_out_event(data)
    end
    it "stores the data we expect" do
      V3::RegistrationService.track_clock_out_event(data)
      te = TrackingEvent.last
      expect(te.source_tracking_id).to eq("123457689")
      expect(te.partner_tracking_id).to eq("22201")
      expect(te.geo_location).to eq({
        "lat" => 123.00, 
        "long" => -123.00
      })
      expect(te.open_tracking_id).to eq("some text")
      expect(te.tracking_data).to eq({
        "canvasser_name" => "A Name",
        "abandoned_registrations" => 3,
        "completed_registrations" => 7,
        "clock_out_datetime" => "2016-06-16T19:44:45+00:00"
      })
    end
  end
  
  

  describe 'data_to_attrs' do
    specify { V3::RegistrationService.send(:data_to_attrs, {}).should == {} }
    specify { V3::RegistrationService.send(:data_to_attrs, { :lang  => 'ex' }).should == { :locale => 'ex' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :survey_question_1 => 'q1' }).should == { :original_survey_question_1 => 'q1' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :survey_question_2 => 'q2' }).should == { :original_survey_question_2 => 'q2' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :source_tracking_id => 'sourceid' }).should == { :tracking_source => 'sourceid' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :partner_tracking_id => 'partnertrackid' }).should == { :tracking_id => 'partnertrackid' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :opt_in_volunteer => true }).should == { :volunteer => true } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :partner_opt_in_volunteer => true }).should == { :partner_volunteer => true } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :home_state_id => 'NY', :mailing_state => 'ca', :prev_state_id => 'Nj' }).should == { :home_state_id => 33, :mailing_state_id => 5, :prev_state_id => 31 } } # See geo_states.csv
    specify { V3::RegistrationService.send(:data_to_attrs, { :id_number => 'id' }).should == { :state_id_number => 'id' } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :IsEighteenOrOlder => true }).should == { :will_be_18_by_election => true } }
    specify { V3::RegistrationService.send(:data_to_attrs, { :is_eighteen_or_older => false }).should == { :will_be_18_by_election => false } }
    
  end

  describe 'find_records' do
    it 'should return an error for invalid partner ID' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      lambda {
        V3::RegistrationService.find_records(:partner_id => 0, :partner_api_key => partner.api_key)
      }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
    end

    it 'should return an error for invalid api_key' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      lambda {
        V3::RegistrationService.find_records(:partner_id => Partner.first.id, :partner_api_key => 'not_the_key')
      }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
    end
    
    it "should return an error for invlaid 'since' value" do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      lambda {
        V3::RegistrationService.find_records(:partner_id => partner.id, :partner_api_key=>partner.api_key, :since => "abcdef")
      }.should raise_error V3::RegistrationService::InvalidParameterValue
    end
    it "should return an error for unsupported parameters" do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      lambda {
        V3::RegistrationService.find_records(:partner_id => Partner.first.id, :some_field => "abcdef")
      }.should raise_error V3::RegistrationService::InvalidParameterType
    end


    it 'should return the list of registrants' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      reg = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner)

      V3::RegistrationService.find_records(:partner_id => partner.id, :partner_api_key => partner.api_key).should == [
        { :status               => 'complete',
          :will_be_18_by_election => reg.will_be_18_by_election?,
          :create_time          => reg.created_at.to_s,
          :complete_time        => reg.updated_at.to_s,
          :lang                 => reg.locale,
          :first_reg            => reg.first_registration?,
          :home_zip_code        => reg.home_zip_code,
          :us_citizen           => reg.us_citizen?,
          :name_title           => reg.name_title,
          :first_name           => reg.first_name,
          :middle_name          => reg.middle_name,
          :last_name            => reg.last_name,
          :name_suffix          => reg.name_suffix,
          :home_address         => reg.home_address,
          :home_unit            => reg.home_unit,
          :home_city            => reg.home_city,
          :home_state_id        => reg.home_state_id,
          :has_mailing_address  => reg.has_mailing_address,
          :mailing_address      => reg.mailing_address,
          :mailing_unit         => reg.mailing_unit,
          :mailing_city         => reg.mailing_city,
          :mailing_state_id     => reg.mailing_state_id,
          :mailing_zip_code     => reg.mailing_zip_code,
          :race                 => reg.race,
          :party                => reg.party,
          :phone                => reg.phone,
          :phone_type           => reg.phone_type,
          :email_address        => reg.email_address,
          :opt_in_email         => reg.opt_in_email,
          :opt_in_sms           => reg.opt_in_sms,
          :opt_in_volunteer     => reg.volunteer?,
          :partner_opt_in_email => reg.partner_opt_in_email,
          :partner_opt_in_sms   => reg.partner_opt_in_sms,
          :partner_opt_in_volunteer    => reg.partner_volunteer,
          :survey_question_1    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_1      => reg.survey_answer_1,
          :survey_question_2    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_2      => reg.survey_answer_2,
          :finish_with_state    => reg.finish_with_state?,
          :created_via_api      => reg.building_via_api_call?,
          :tracking_source      => reg.tracking_source,
          :tracking_id         => reg.tracking_id,
          :dob                  => reg.pdf_date_of_birth}
      ]
    end

    it 'should not list registrants before the since date' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      reg = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner)

      V3::RegistrationService.find_records(:partner_id => partner.id, :partner_api_key => partner.api_key, :since => 1.minute.from_now.to_s).should == []
    end

    it 'should filter by email address' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      reg = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner, :email_address=>"test@osdv.org")
      reg2 = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner, :email_address=>"test2@osdv.org")

      res = V3::RegistrationService.find_records(:partner_id => partner.id,
        :partner_api_key => partner.api_key,
        :email => "test@osdv.org")
      res.first[:email_address].should == reg.email_address
      res.should have(1).registrant
      res2 = V3::RegistrationService.find_records(:partner_id => partner.id,
        :partner_api_key => partner.api_key,
        :email => "test2@osdv.org")
      res2.first[:email_address].should == reg2.email_address
      res2.should have(1).registrant
    end


    it 'should filter by email address and since date' do
      partner = FactoryGirl.create(:partner, :api_key=>"key")
      reg = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner, :email_address=>"test@osdv.org")
      reg2 = FactoryGirl.create(:api_v3_maximal_registrant, :partner => partner, :email_address=>"test2@osdv.org")

      V3::RegistrationService.find_records(:partner_id => partner.id,
        :partner_api_key => partner.api_key,
        :email => "test@osdv.org",
        :since => 1.minute.from_now.to_s).should == []

      res = V3::RegistrationService.find_records(:partner_id => partner.id,
          :partner_api_key => partner.api_key,
          :email => "test@osdv.org",
          :since => 1.day.ago.to_s)
      res.first[:email_address].should == reg.email_address
      res.should have(1).registrant
    end

    context "when a gpartner_id is passed in" do
      before(:each) do
        @partner = FactoryGirl.create(:government_partner, :api_key=>"key")
        @ma_reg = FactoryGirl.create(:maximal_registrant, :home_zip_code=>"02110")
        @ca_reg = FactoryGirl.create(:maximal_registrant, :home_zip_code=>"90000")
      end
      context "when the gpartner ID is invalid" do
        it "should return an error" do
          lambda {
            V3::RegistrationService.find_records(:gpartner_id => 0, :gpartner_api_key => @partner.api_key)
          }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
        end
      end
      context "when the API key doesn't match" do
        it "should return an error" do
          lambda {
            V3::RegistrationService.find_records(:gpartner_id => @partner.id, :gpartner_api_key => 'not_the_key')
          }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY          
        end
      end
      context "when the gpartner zips are set by state" do
        before(:each) do
          @partner.government_partner_state_abbrev = "MA"
          @partner.government_partner_zip_code_list = nil
          @partner.save!
        end
        it "should return registrants for that state" do
          results = V3::RegistrationService.find_records(:gpartner_id => @partner.id, :gpartner_api_key => @partner.api_key)
          results.should have(1).registrants
          results.first[:email_address].should == @ma_reg.email_address
        end
      end
      context "when the gpartner zips are set by zip-code list" do
        it "should return registrants for those zip codes only (regardless of state)" do
          @partner.government_partner_zip_code_list = "02113, 90000"
          @partner.save!
          results = V3::RegistrationService.find_records(:gpartner_id => @partner.id, :gpartner_api_key => @partner.api_key)
          results.should have(1).registrants
          results.first[:email_address].should == @ca_reg.email_address

          @partner.government_partner_zip_code_list = "02110, 90000"
          @partner.save!
          results = V3::RegistrationService.find_records(:gpartner_id => @partner.id, :gpartner_api_key => @partner.api_key)
          results.should have(2).registrants
        end        
      end
    end
  end

  describe 'check_pdf_ready' do
    let(:query) do
      { :UID=>"123"}
    end
    let(:reg) { mock_model(Registrant) }
    before(:each) do
      Registrant.stub(:find_by_uid).and_return(reg)
      reg.stub(:pdf_ready?).and_return(true)
    end
    it "raises an error when the registrant isn't found" do
      Registrant.stub(:find_by_uid).and_return(nil)
      lambda {
        V3::RegistrationService.check_pdf_ready(query)
      }.should raise_error(V3::RegistrationService::InvalidUIDError)
    end
    
    it "finds the registrant" do
      Registrant.should_receive(:find_by_uid).with("123")
      V3::RegistrationService.check_pdf_ready(query).should be_truthy
    end
    it "returns false if the registrant pdf is not ready" do
      reg.stub(:pdf_ready?).and_return(false)
      V3::RegistrationService.check_pdf_ready(query).should be_falsey
    end
  end

  describe 'stop_reminders' do
    let(:query) do
      { :UID=>"123"}
    end
    let(:reg) { mock_model(Registrant) }
    before(:each) do
      reg.stub(:email_address).and_return("email_addr")
      reg.stub(:first_name).and_return("fn")
      reg.stub(:last_name).and_return("ln")
      reg.stub(:finish_iframe_url).and_return("iurl")
      reg.stub(:locale).and_return('loc')
      reg.stub(:partner_id).and_return('id')
      reg.stub(:update_attributes).and_return(true)
      Registrant.stub(:find_by_uid).and_return(reg)
    end
    it "raises an error when the registrant isn't found" do
      Registrant.stub(:find_by_uid).and_return(nil)
      lambda {
        V3::RegistrationService.stop_reminders(query)
      }.should raise_error(V3::RegistrationService::InvalidUIDError)
    end
    it "finds the registrant" do
      Registrant.should_receive(:find_by_uid).with("123")
      V3::RegistrationService.stop_reminders(query)
    end
    it "sets the registrant reminders_left to 0" do
      reg.should_receive(:update_attributes).with(:reminders_left=>0)
      V3::RegistrationService.stop_reminders(query)
    end
    it "returns wether the update was successful" do
      V3::RegistrationService.stop_reminders(query)[:reminders_stopped].should be_truthy
      reg.stub(:update_attributes).and_return(false)
      V3::RegistrationService.stop_reminders(query)[:reminders_stopped].should be_falsey      
    end
    it "returns first name, last name and email address" do
      r = V3::RegistrationService.stop_reminders(query)
      r[:email_address].should == "email_addr"
      r[:first_name].should == "fn"
      r[:last_name].should == "ln"
      r[:finish_iframe_url].should == "iurl"
      r[:partner_id].should == "id"
      r[:locale].should == "loc"
    end
  end


  # describe 'bulk_create' do
  #   let(:data_list) do
  #     [FactoryGirl.create(:step_1_registrant, :remote_partner_id=>1, :partner_id=>nil).to_bulk_api_hash,
  #     FactoryGirl.create(:step_2_registrant).to_bulk_api_hash,
  #     FactoryGirl.create(:step_3_registrant, :remote_partner_id=>1, :partner_id=>nil).to_bulk_api_hash,
  #     FactoryGirl.create(:step_4_registrant).to_bulk_api_hash]
  #   end
  #   let(:partner) { FactoryGirl.create(:partner, :api_key=>"key") }
  #   it "checks partner API key" do
  #     lambda {
  #       V3::RegistrationService.bulk_create(data_list, 0,  "asdasd")
  #     }.should raise_error V3::PartnerService::INVALID_PARTNER_OR_API_KEY
  #   end
  #
  #   it "creates a reg record for each item in the api-style data list" do
  #     data_list.each do |data_item|
  #       V3::RegistrationService.stub(:block_protected_attributes)
  #       V3::RegistrationService.should_receive(:block_protected_attributes).with(data_item)
  #       V3::RegistrationService.stub(:data_to_attrs)
  #       V3::RegistrationService.should_receive(:data_to_attrs).with(data_item).and_return(data_item)
  #       reg = mock_model(Registrant)
  #       reg.stub(:status=)
  #       reg.stub(:save!)
  #       Registrant.stub(:new)
  #       Registrant.should_receive(:new).with(data_item).and_return(reg)
  #       reg.should_receive(:status=).with(data_item[:status])
  #       reg.should_receive(:save!)
  #     end
  #     V3::RegistrationService.bulk_create(data_list, partner.id, partner.api_key)
  #   end
  #
  #   it "returns a 1-1 array of success/failures for the data list" do
  #     results = V3::RegistrationService.bulk_create(data_list, partner.id, partner.api_key)
  #     results[0][0].should be_truthy
  #     results[1][0].should be_falsey
  #     results[2][0].should be_truthy
  #     results[3][0].should be_falsey
  #   end
  # end
end
