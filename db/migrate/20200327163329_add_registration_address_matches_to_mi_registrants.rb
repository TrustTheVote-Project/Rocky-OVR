class AddRegistrationAddressMatchesToMiRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_mi_registrants, :registration_address_matches, :text
  end
end
