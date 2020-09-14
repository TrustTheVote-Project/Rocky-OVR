class AddStatusCheckUrlToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :status_check_url, :string
  end
end
