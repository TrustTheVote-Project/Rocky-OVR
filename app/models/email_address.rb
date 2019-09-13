class EmailAddress < ActiveRecord::Base
  validates_uniqueness_of :email_address
  validates_presence_of :email_address
  validates_format_of :email_address, :with => Authlogic::Regex::EMAIL
  attr_protected :blacklisted
  def self.is_blacklisted?(email_address)
    email_address = email_address.to_s.strip.downcase
    return true if email_address == "test@test.com" 
    EmailAddress.where(email_address: email_address, blacklisted: true).count > 0 || EmailDomain.is_blacklisted?(email_address)
  end
end
