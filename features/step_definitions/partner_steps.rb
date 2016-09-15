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



Given /^that partner's css file exists$/ do
  File.stub(:exists?).and_return(true)
end

Given /^that partner's assets do not exist$/ do
  allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
end


Given(/^partner's assets exist:$/) do |table|
  @fs3 = FakeS3.new(table.hashes.map { |item| File.join(@partner.assets_path, item[:asset]) })
  allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(@fs3)
end

Given /^that partner's css file does not exist$/ do
  Partner.any_instance.stub(:application_css_present?).and_return(false)
  Partner.any_instance.stub(:registration_css_present?).and_return(false)
  # @partner.stub(:application_css_present?).and_return(false)
  # @partner.stub(:registration_css_present?).and_return(false)
end



Then /^I should see a link to the standard CSS$/ do
  page.body.should include("link href=\"/assets/application.css")
  page.body.should include("link href=\"/assets/registration.css")
end


Then /^I should see a link to that partner's CSS$/ do
  page.body.should include("link href=\"#{@partner.application_css_url}")
  page.body.should include("link href=\"#{@partner.registration_css_url}")
end

Then /^preview\/(application|registration|partner).css should be loaded$/ do |asset|
  method = "#{asset}_css_url"
  page.body.should include("link href=\"#{@partner.send(method, :preview)}")
end

Then /^system (application|registration).css should be loaded$/ do |asset|
  page.body.should include("link href=\"/assets/#{asset}.css")
end


Then /^that partner's API code should not be blank$/ do
  @partner ||= Partner.last
  @partner.reload
  @partner.api_key.should_not be_blank
end

Then /^that partner's government_partner_state should be "([^\"]*)"$/ do |state_abbr|
  @partner ||= Partner.last
  @partner.reload
  @partner.government_partner_state_abbrev.should == state_abbr
end

Then /^that partner's zip code list should be "([^\"]*)"$/ do |comma_separated_list|
  @partner ||= Partner.last
  @partner.reload
  @partner.government_partner_zip_codes.join(", ").should == comma_separated_list.to_s
end

Then(/^(approved|non-approved) assets are (empty|.*)$/) do |type, list|
  selector = (type == 'approved' ? '.approved' : '.not_approved') + ' .asset'
  items = list == 'empty' ? [] : list.split(', ')
  found = page.all(selector).map(&:text)
  expect(found).to match_array(items)
end

Then (/^I should be redirected to the right preview URL$/) do
  # 'http://www.example.com/registrants/new?partner=3&preview_custom_assets='

  expect(current_url).to start_with('http://www.example.com/registrants/new?')
  params = URI::decode_www_form(URI(current_url).query)
  expect(params.assoc('partner')).to include (Partner.last.id.to_s)
  expect(params.assoc('preview_custom_assets')).not_to be_nil
end

And(/^Assets "(not set|not changed)" warning should be shown$/) do |type|
  warning_type = type == 'not set' ? :not_set : :not_changed
  msg = I18n::t('partners.branding.preview_warning')[warning_type]
  # current driver is not using JS, this tests rails confirm helper:
  page.should have_css "a[data-confirm=\"#{msg}\"]"
end

And(/^Assets status warning is not shown$/) do
  # current driver is not using JS, this tests rails confirm helper:
  page.should have_css "a[data-confirm=\"\"]"
end

Then(/^changes are published$/) do
  # emulates admin's publishing in background
  @partner.folder.publish_sub_assets(:preview)
end

Then(/^fake registrant is created$/) do
  @registrant = @partner.registrants.last
  expect(@registrant.is_fake).to be true
end

Given(/^fake registrant finished registration$/) do
  @registrant = FactoryGirl.create("step_5_registrant", is_fake: true, partner: @partner)
end

Then(/^registrant pdf includes "([^"]+)"$/) do |text|
  source = @registrant.pdf_writer.registrant_to_html_string
  expect(source).to include(text)
end

Given(/^settings partner wiki url is "([^"]*)"$/) do |url|
  expect(RockyConf).to receive(:partner_wiki_url).at_least(:once).and_return(url)
end