class AddShiftSourceToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :shift_source, :string
  end
end
