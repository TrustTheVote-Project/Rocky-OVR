class AddPdfAssistanceEnabledToGeoStates < ActiveRecord::Migration
  def change
    add_column :geo_states, :pdf_assistance_enabled, :boolean
  end
end
