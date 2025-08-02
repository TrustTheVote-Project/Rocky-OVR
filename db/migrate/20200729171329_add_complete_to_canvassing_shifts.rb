class AddCompleteToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :complete, :boolean
  end
end
