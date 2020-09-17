class AddBlocksTurfIdToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :blocks_turf_id, :string
  end
end
