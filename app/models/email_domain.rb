class EmailDomain < ActiveRecord::Base
  validates_uniqueness_of :domain
  validates_presence_of :domain
  attr_protected :blacklisted
  def self.is_blacklisted?(email_address_or_domain)
    domain = email_address_or_domain.to_s.strip.downcase.gsub(/^[^@]+@/,'').strip
    EmailDomain.where(domain: domain, blacklisted: true).count > 0
  end
end
