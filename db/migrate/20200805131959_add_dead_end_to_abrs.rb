class AddDeadEndToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :dead_end, :boolean, default: false
  end
end
