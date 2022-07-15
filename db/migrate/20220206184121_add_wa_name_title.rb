class AddWaNameTitle < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_wa_registrants, :name_title, :string
  end
    
end
