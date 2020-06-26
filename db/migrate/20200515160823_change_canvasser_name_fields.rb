class ChangeCanvasserNameFields < ActiveRecord::Migration
  def change
    remove_column :canvassing_shifts, :canvasser_name
    add_column :canvassing_shifts, :canvasser_first_name, :string
    add_column :canvassing_shifts, :canvasser_last_name, :string
    add_column :canvassing_shifts, :canvasser_email, :string
    add_index :canvassing_shifts, [:canvasser_first_name, :canvasser_last_name], name: :shift_canvasser_name_index
  end
end
