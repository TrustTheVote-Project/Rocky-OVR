class AddWaStateHomelessNoDln < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_wa_registrants, :confirm_no_dln,  :boolean
    add_column :state_registrants_wa_registrants, :homeless_address, :string
  end
end
