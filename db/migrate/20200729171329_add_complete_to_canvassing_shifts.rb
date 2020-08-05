class AddCompleteToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :complete, :boolean
  end
end
