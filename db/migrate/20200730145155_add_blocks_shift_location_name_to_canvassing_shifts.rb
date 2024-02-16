class AddBlocksShiftLocationNameToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :blocks_shift_location_name, :string
  end
end
