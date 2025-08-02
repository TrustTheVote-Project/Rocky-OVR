class AddNotesToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :notes, :text
  end
end
