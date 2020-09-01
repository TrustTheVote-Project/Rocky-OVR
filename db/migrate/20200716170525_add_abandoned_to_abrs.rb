class AddAbandonedToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :abandoned, :boolean
  end
end
