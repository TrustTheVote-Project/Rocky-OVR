class IndexTrackingEventOnName < ActiveRecord::Migration[5.2]
  def change
    add_index :tracking_events, :tracking_event_name
  end
end
