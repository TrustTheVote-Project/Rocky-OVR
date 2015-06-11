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

describe V1::RegistrationService do

  describe 'create_record' do
    it 'should raise an error if the language is unknown' do
      lambda { V1::RegistrationService.create_record(:lang => 'unknown') }.should raise_error V1::UnsupportedLanguageError
    end

    it 'should raise an error if the field is unknown' do
      begin
        V1::RegistrationService.create_record(:lang => 'en', :unknown => 'field')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: unknown'
      end
    end

    it 'should not know state_id_number field' do
      begin
        V1::RegistrationService.create_record(:lang => 'en', :state_id_number => '1234')
        fail "UnknownAttributeError expected"
      rescue ActiveRecord::UnknownAttributeError => e
        e.message.should == 'unknown attribute: state_id_number'
      end
    end

    it 'should raise validation errors when the record is invalid' do
      begin
        V1::RegistrationService.create_record(:lang => 'en')
        fail 'ValidationError is expected'
      rescue V1::RegistrationService::ValidationError => e
        e.field.to_s.should    == 'date_of_birth'
        e.message.should  == "Required"
      end
    end

    it 'should raise an error if the language is unknown even if everything else is bad' do
      lambda {
        V1::RegistrationService.create_record(:lang => 'ex', :home_state_id => 1)
      }.should raise_error V1::UnsupportedLanguageError
    end

    it 'should raise an error if the language is not given' do
      begin
        V1::RegistrationService.create_record(:home_state_id => 'NY')
        fail 'ValidationError is expected'
      rescue V1::RegistrationService::ValidationError => e
        e.field.should.to_s    == 'lang'
        e.message.should  == 'Required'
      end
    end

    it 'should deal with states passed as strings' do
      V2::RegistrationService.data_to_attrs({
              :mailing_state => "", :home_state => "1", :prev_state => "AL"
            }).should == {
              :mailing_state_id => nil,
              :home_state_id => nil,
              :prev_state_id => 1,
            }
    end

    context 'complete record' do
      before { @reg = FactoryGirl.create(:maximal_registrant, :status => 'step_5') }
      before { Registrant.stub(:build_from_api_data).with({}) { @reg } }

      it 'should save the record and generate PDF' do
        @reg.stub(:enqueue_complete_registration_via_api)
        V1::RegistrationService.create_record({}).should
      end
    end
  end

  describe 'data_to_attrs' do
    specify { V1::RegistrationService.send(:data_to_attrs, {}).should == {} }
    specify { V1::RegistrationService.send(:data_to_attrs, { :lang  => 'ex' }).should == { :locale => 'ex' } }
    specify { V1::RegistrationService.send(:data_to_attrs, { :partner_tracking_id => 'id' }).should == { :tracking_source => 'id' } }
    specify { V1::RegistrationService.send(:data_to_attrs, { :home_state_id => 'NY', :mailing_state => 'ca', :prev_state_id => 'Nj' }).should == { "home_state_id" => 33, "mailing_state_id" => 5, "prev_state_id" => 31 } } # See geo_states.csv
    specify { V1::RegistrationService.send(:data_to_attrs, { :id_number => 'id' }).should == { :state_id_number => 'id' } }
  end

  describe 'find_records' do
    it 'should return an error for invalid partner ID' do
      lambda {
        V1::RegistrationService.find_records(:partner_id => 0, :partner_password => 'password')
      }.should raise_error V1::RegistrationService::INVALID_PARTNER_OR_PASSWORD
    end

    it 'should return an error for invalid password' do
      lambda {
        V1::RegistrationService.find_records(:partner_id => Partner.first.id, :partner_password => 'invalid_password')
      }.should raise_error V1::RegistrationService::INVALID_PARTNER_OR_PASSWORD
    end

    it 'should return the list of registrants' do
      partner = Partner.first
      reg = FactoryGirl.create(:maximal_registrant, :partner => partner)

      V1::RegistrationService.find_records(:partner_id => partner.id, :partner_password => 'password').should == [
        { :status               => 'complete',
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
          :survey_question_1    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_1      => reg.survey_answer_1,
          :survey_question_2    => partner.send("survey_question_1_#{reg.locale}"),
          :survey_answer_2      => reg.survey_answer_2,
          :volunteer            => reg.volunteer? }
      ]
    end

    it 'should not list registrants before the since date' do
      partner = Partner.first
      reg = FactoryGirl.create(:maximal_registrant, :partner => partner)

      V1::RegistrationService.find_records(:partner_id => partner.id, :partner_password => 'password', :since => 1.minute.from_now.to_s).should == []
    end
  end

end
