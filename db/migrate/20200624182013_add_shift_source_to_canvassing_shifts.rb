class AddShiftSourceToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :shift_source, :string
  end
end
