module UidGenerator
  extend ActiveSupport::Concern

  included do
    before_create :generate_uid
  end

  def generate_uid
    self.uid = Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{email} -- #{zip}" )
  end
end
