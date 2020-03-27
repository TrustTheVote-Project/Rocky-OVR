class AddPostDirectionalToMiRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_mi_registrants, :registration_address_post_directional, :string
  end
end
