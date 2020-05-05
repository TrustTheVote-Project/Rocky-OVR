class CreateCanvassingShiftRegistrations < ActiveRecord::Migration
  def change
    create_table :canvassing_shift_registrations do |t|
      t.string :registrant_id
      t.string :shift_external_id
      t.timestamps null: false
    end
    add_index :canvassing_shift_registrations, :registrant_id
    add_index :canvassing_shift_registrations, :shift_external_id
  end
end
