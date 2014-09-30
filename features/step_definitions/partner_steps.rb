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

Given /^that partner's css file does not exist$/ do
  File.stub(:exists?).and_return(false)
end



Then /^I should see a link to the standard CSS$/ do
  page.body.should include("link href=\"/assets/application.css")
  page.body.should include("link href=\"/assets/registration.css")
end


Then /^I should see a link to that partner's CSS$/ do
  page.body.should include("link href=\"//#{@partner.partner_assets_host}/partners/#{@partner.id}/application.css")
  page.body.should include("link href=\"//#{@partner.partner_assets_host}/partners/#{@partner.id}/registration.css")
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
