class AddAbandonedToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :abandoned, :boolean
  end
end
