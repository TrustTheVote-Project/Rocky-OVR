class AddCatalistUpdatedAtToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :catalist_updated_at, :date
  end
end
