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
class Admin < ActiveRecord::Base
  acts_as_google_authenticated method: :email_with_label

  acts_as_authentic do |c|
    c.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  def email_with_label
    "RTV Admin #{env_label}(#{email})"
  end

  def env_label
    Rails.env.production? ? '' : "- #{Rails.env} "
  end
  
  validates_format_of :email, :with => Registrant::EMAIL_REGEX, :allow_blank => true
  
  
  validates :password,
    confirmation: { if: :require_password? },
    format: {
      # Symbols: $@$!%*?&
      with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{10,}/, 
      allow_blank: true
    },
    length: {
      minimum: 10,
      if: :require_password?
    }
  validates :password_confirmation,
    length: {
      minimum: 10,
      if: :require_password?
    }

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.admin_password_reset_instructions(self).deliver_now
  end
  
end
