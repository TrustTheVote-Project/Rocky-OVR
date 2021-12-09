class ChaserDelivery < ApplicationRecord
  belongs_to :registrant, optional: true
  belongs_to :abr, optional: true
  
  def self.can_send_chaser?(email)
    prev_delivery = ChaserDelivery.where(email: email).where("created_at > ?", RockyConf.hours_before_chaser_redelivery.hours.ago)
    return prev_delivery.count == 0
  end
end
