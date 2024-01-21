class RemoveRedirectToOnlineRegistrationUrlFromGeoStates < ActiveRecord::Migration[4.2]
  def up
    remove_column :geo_states, :redirect_to_online_registration_url
  end

  def down
    add_column :geo_states, :redirect_to_online_registration_url, :boolean
  end
end
