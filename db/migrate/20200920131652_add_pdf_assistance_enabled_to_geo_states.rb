class AddPdfAssistanceEnabledToGeoStates < ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :pdf_assistance_enabled, :boolean
  end
end
