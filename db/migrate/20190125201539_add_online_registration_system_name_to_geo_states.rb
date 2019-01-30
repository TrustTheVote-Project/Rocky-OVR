class AddOnlineRegistrationSystemNameToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :online_registration_system_name, :string
  end
end
