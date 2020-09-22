class AddCatalistUpdatedAtToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :catalist_updated_at, :date
  end
end
