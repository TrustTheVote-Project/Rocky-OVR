class AddBlocksShiftIdToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :blocks_shift_id, :string, index: true
  end
end
