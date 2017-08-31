class CreateTrackingEvents < ActiveRecord::Migration
  def change
    create_table :tracking_events do |t|
      t.string :tracking_event_name
      t.string :source_tracking_id
      t.string :partner_tracking_id
      t.string :open_tracking_id

      t.text :geo_location
      
      t.text :tracking_data
      
      t.timestamps
    end
  end
end
