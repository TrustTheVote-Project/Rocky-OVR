require 'resolv'

class MxEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    domain = value.to_s.split('@').last
    return if domain.blank?

    mx_records = Resolv::DNS.open do |dns|
      dns.timeouts = 3
      dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
    end

    if mx_records.empty?
      record.errors.add(attribute, :mx_invalid)
    end
  rescue StandardError
    # Fail open - don't block registration on any DNS/network error
  end
end
