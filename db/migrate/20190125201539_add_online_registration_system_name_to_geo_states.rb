class AddOnlineRegistrationSystemNameToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :online_registration_system_name, :string
  end
end
