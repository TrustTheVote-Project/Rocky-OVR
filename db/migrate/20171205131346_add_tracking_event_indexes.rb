class AddTrackingEventIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :tracking_events, :source_tracking_id
    add_index :tracking_events, :partner_tracking_id
    add_index :tracking_events, :open_tracking_id
  end
end
