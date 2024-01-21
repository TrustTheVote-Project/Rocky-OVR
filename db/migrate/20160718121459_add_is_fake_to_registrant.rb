class AddIsFakeToRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :is_fake, :boolean, default: false
  end
end
