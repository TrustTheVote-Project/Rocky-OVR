class AddBlocksTurfIdToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :blocks_turf_id, :string
  end
end
