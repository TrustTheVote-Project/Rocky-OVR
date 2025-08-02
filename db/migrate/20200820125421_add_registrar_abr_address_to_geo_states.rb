class AddRegistrarAbrAddressToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :registrar_abr_address, :string
  end
end
