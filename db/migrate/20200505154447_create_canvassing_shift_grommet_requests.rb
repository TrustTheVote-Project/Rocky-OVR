class CreateCanvassingShiftGrommetRequests < ActiveRecord::Migration
  def change
    create_table :canvassing_shift_grommet_requests do |t|
      t.string :grommet_request_id
      t.string :shift_external_id
      t.timestamps null: false
    end
    add_index :canvassing_shift_grommet_requests, :grommet_request_id
    add_index :canvassing_shift_grommet_requests, :shift_external_id
  end
end
