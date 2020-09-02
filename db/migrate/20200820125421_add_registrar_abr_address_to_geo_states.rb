class AddRegistrarAbrAddressToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :registrar_abr_address, :string
  end
end
