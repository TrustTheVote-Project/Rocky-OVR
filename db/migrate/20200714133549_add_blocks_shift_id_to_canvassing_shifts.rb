class AddBlocksShiftIdToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :blocks_shift_id, :string, index: true
  end
end
