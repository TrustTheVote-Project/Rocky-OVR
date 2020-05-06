class CreateBlocksServiceBulkSubmissions < ActiveRecord::Migration
  def change
    create_table :blocks_service_bulk_submissions do |t|
      t.datetime :shift_start
      t.datetime :shift_end
      t.text :partners_submitted
      t.timestamps null: false
    end
  end
end
