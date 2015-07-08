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

When /^I upload the "([^\"]*)" zip file$/ do |file_name|
  attach_file(:partner_zip_zip_file, File.join(Rails.root, 'spec', 'fixtures', 'files', file_name))
end

Then /^I should see that partner's api key$/ do
  @partner ||= Partner.last
  @partner.api_key.should_not be_blank
  page.should have_content(@partner.api_key)
end


Given /^that partner's api key is "([^\"]*)"$/ do |key|
  @partner ||= Partner.last
  @partner.update_attributes!(:api_key=>key)
end


Then /^that partner's api key should not be "([^\"]*)"$/ do |old_key|
  @partner ||= Partner.last
  @partner.reload
  @partner.api_key.should_not == old_key
end


Then(/^I should see an email body field for "(.*?)" for each language$/) do |template_label|
  I18n.available_locales.each do |loc|
    t_name = EmailTemplate::TEMPLATE_NAMES.to_a.detect{|nl| nl[1]=="#{template_label} #{loc.to_s.upcase}" }
    page.should have_field("template[#{t_name[0]}]")
  end
end

Then(/^I should see an email subject field for "(.*?)" for each langauge$/) do |template_label|
  I18n.available_locales.each do |loc|
    t_name = EmailTemplate::TEMPLATE_NAMES.to_a.detect{|nl| nl[1]=="#{template_label} #{loc.to_s.upcase}" }
    page.should have_field("template_subject[#{t_name[0]}]")
  end
  
end

Then(/^I should see a pixel tracking field for "(.*?)"$/) do |email_type|
  page.should have_field("partner[#{email_type}_pixel_tracking_code]")  
end