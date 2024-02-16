class AddStatusCheckUrlToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :status_check_url, :string
  end
end
