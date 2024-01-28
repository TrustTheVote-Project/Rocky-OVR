class AddOnlineRegUrlToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :online_registration_url, :string
  end
end
