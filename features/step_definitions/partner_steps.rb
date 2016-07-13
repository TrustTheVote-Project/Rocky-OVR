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
  PartnerAssetsFolder.any_instance.stub(:list_assets).and_return([])
  PartnerAssetsFolder.any_instance.stub(:directory).and_return(OpenStruct.new(files: []))
end


Given(/^partner's assets exist:$/) do |table|
  @partner ||= Partner.last
  assets = table.hashes.map { |item| item[:asset] }

  assets_paths = assets.map { |asset| File.join(@partner.assets_path, asset)}
  PartnerAssetsFolder.any_instance.stub(:list_assets).and_return(assets_paths)

  files = assets.map do |asset|
    path = File.join(@partner.assets_path, asset)
    double(key: path, public_url: 'https://' + File.join(@partner.assets_path, asset))
  end
  PartnerAssetsFolder.any_instance.stub(:directory).and_return(double(files: files))
end

Given /^that partner's css file does not exist$/ do
  @partner ||= Partner.last
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
  method = "sub_#{asset}_css_url"
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

Then(/^The "([^"]*)" css is "([^"]*)"$/) do |_, _, table|
  table.hashes.each do |pair|
    css = pair[:css]
    status = pair[:status]
    page.body.should include "#{css}.css (#{status})" if status == 'missing'
  end
end

Then(/^(approved|non-approved) assets are (empty)$/) do |type, list|
  selector = (type == 'approved' ? 'approved' : 'not_approved') + ' .asset'
  expect(page.all(selector)).to be_empty
end

Then (/^I should be redirected to the right preview URL$/) do
  # 'http://www.example.com/registrants/new?partner=3&preview_custom_assets='

  expect(current_url).to start_with('http://www.example.com/registrants/new?')
  params = URI::decode_www_form(URI(current_url).query)
  expect(params.assoc('partner')).to include (Partner.last.id.to_s)
  expect(params.assoc('preview_custom_assets')).not_to be_nil
end
