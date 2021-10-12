class AddAbrBaiscConfigsToGeoStates < ActiveRecord::Migration[5.2]
  def change
    add_column :geo_states, :abr_deadline_passed, :boolean
    add_column :geo_states, :abr_splash_page, :boolean
  end
end
