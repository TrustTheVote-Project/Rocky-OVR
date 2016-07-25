class AddIsFakeToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :is_fake, :boolean, default: false
  end
end
