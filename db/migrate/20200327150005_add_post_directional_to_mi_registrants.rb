class AddPostDirectionalToMiRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_mi_registrants, :registration_address_post_directional, :string
  end
end
