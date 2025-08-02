class AddOptionalPartyToGeoStates < ActiveRecord::Migration[5.2]
  def change
    add_column :geo_states, :optional_party, :boolean
  end
end
