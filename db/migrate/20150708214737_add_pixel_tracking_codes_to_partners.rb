class AddPixelTrackingCodesToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :pixel_tracking_codes, :text
  end
end
