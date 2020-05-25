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
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

# Commonly used webrat steps
# http://github.com/brynary/webrat

Then(/^I should not see the canvassing notice bar$/) do
  page.should_not have_selector("#canvasser-notice")
end

Then(/^I should see the canvassing notice bar$/) do
  page.should have_selector("#canvasser-notice")
end

Then /^"([^"]*)" select box should contain "([^"]*)"$/ do |dropdown, text|
  puts Partner.all.collect {|p| [p.id, p.name]}
  #save_and_open_page
  expect(page).to have_select(dropdown, with_options: [text])
end


Given(/^that I started a new shift for partner="(\d+)"$/) do |partner_id|
  @partner = FactoryGirl.create(:partner, id: partner_id)
  step %{I go to the shift creation page for partner="#{partner_id}"}
  step %{I fill in "First Name" with "Test"}
  step %{I fill in "Last Name" with "Test"}
  step %{I fill in "Phone" with "123-123-1234"}
  step %{I fill in "Email" with "abc@def.ghi"}
  step %{I select "Default Location" from "Location"}
  step %{I click "Start Shift"}
end
