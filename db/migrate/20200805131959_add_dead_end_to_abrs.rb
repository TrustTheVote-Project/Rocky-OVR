class AddDeadEndToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :dead_end, :boolean, default: false
  end
end
