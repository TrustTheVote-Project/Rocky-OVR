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
require 'rails_helper'

describe EmailTemplate do

  let(:partner) { FactoryGirl.create(:partner, whitelabeled: true) }
  let(:registrant) { FactoryGirl.create(:maximal_registrant, partner: partner) }

  it 'has custom templates compatible with mailer templates' do
    initial_templates = {}
    updated_templates = {}
    EmailTemplate::TEMPLATE_NAMES.each do |name, _|
      type, locale = name.split(".")
      registrant.locale = locale
      allow(registrant).to receive(:home_state_email_instructions).and_return("")
      
      initial_templates[name] = Notifier.send(type, registrant).body.to_s

      EmailTemplate.set(partner, name, EmailTemplate.default(name) + "UNIQUE_VALUE_TO_BE_DELETED")
      updated_templates[name] = Notifier.send(type, registrant).body.to_s
    end

    EmailTemplate::TEMPLATE_NAMES.each do |name, _|

      new_value = updated_templates[name].sub("UNIQUE_VALUE_TO_BE_DELETED", "")
      expect(new_value).to eql(initial_templates[name])
    end

  end

  it 'does not store default subject and body' do
    name = "confirmation.es"

    EmailTemplate.set(partner, name, "AAA")
    EmailTemplate.set_subject(partner, name, "BBB")

    t = EmailTemplate.find_by_partner_id_and_name(partner.id, name)
    expect(t.body).to eql("AAA")
    expect(t.subject).to eql("BBB")
    expect(EmailTemplate.get(partner, name)).to eql("AAA")
    expect(EmailTemplate.get_subject(partner, name)).to eql("BBB")

    default_body = EmailTemplate.default(name)
    default_subject = EmailTemplate.default_subject(name)

    EmailTemplate.set(partner, name, default_body)
    EmailTemplate.set_subject(partner, name, default_subject)

    # saved values are empty
    t = EmailTemplate.find_by_partner_id_and_name(partner.id, name)
    expect(t.body).to be_empty
    expect(t.subject).to be_empty
    # but getters return default values
    expect(EmailTemplate.get(partner, name)).to eql(default_body)
    expect(EmailTemplate.get_subject(partner, name)).to eql(default_subject)
  end
end
