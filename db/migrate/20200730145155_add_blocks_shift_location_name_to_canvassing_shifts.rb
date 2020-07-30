class AddBlocksShiftLocationNameToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :blocks_shift_location_name, :string
  end
end
