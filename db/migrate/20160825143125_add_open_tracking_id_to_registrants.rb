class AddOpenTrackingIdToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :open_tracking_id, :string
  end
end
