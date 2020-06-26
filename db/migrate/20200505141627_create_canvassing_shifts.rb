class CreateCanvassingShifts < ActiveRecord::Migration
  def change
    create_table :canvassing_shifts do |t|
      t.integer :partner_id
      t.string :shift_location
      t.text :geo_location

      t.string :shift_external_id
      t.string :source_tracking_id
      t.string :partner_tracking_id
      t.string :open_tracking_id
      
      t.string :device_id
      
      t.datetime :clock_in_datetime
      t.datetime :clock_out_datetime
      
      t.integer :abandoned_registrations
      t.integer :completed_registrations
      
      t.string :canvasser_name
      t.string :canvasser_phone
      
      t.timestamps null: false
    end
    add_index :canvassing_shifts, :partner_id
    add_index :canvassing_shifts, :shift_location
    add_index :canvassing_shifts, :shift_external_id
    add_index :canvassing_shifts, :source_tracking_id
    add_index :canvassing_shifts, :partner_tracking_id
    add_index :canvassing_shifts, [:partner_id, :canvasser_name], name: :canvasser_index
    
  end
end
