class ChangeAbrAddress < ActiveRecord::Migration[4.2]
  def change
    remove_column :abrs, :address
    add_column :abrs, :street_number, :string
    add_column :abrs, :street_name, :string
    add_column :abrs, :street_line2, :string
    add_column :abrs, :unit, :string
  end
end
