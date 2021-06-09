class AddNotesToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :notes, :text
  end
end
