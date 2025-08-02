class AddRegistrationAddressMatchesToMiRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_mi_registrants, :registration_address_matches, :text
  end
end
