class EmailAddress < ActiveRecord::Base
  def self.is_blacklisted?(email_address)
    EmailAddress.where(email_address: email_address, blacklisted: true).count > 0
  end
end
