class AddRedirectToOnlineRegistrationUrlToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :redirect_to_online_registration_url, :boolean
  end
end
