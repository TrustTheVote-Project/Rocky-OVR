class AddOpenTrackingIdToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :open_tracking_id, :string
  end
end
