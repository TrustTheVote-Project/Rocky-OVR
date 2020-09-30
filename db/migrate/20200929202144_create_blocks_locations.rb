class CreateBlocksLocations < ActiveRecord::Migration
  def change
    create_table :blocks_locations do |t|
      t.string :blocks_id, index: true
      t.string :name

      t.timestamps null: false
    end
  end
end
