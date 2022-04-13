class AddAbrSettingsToGeoStates < ActiveRecord::Migration[5.2]
  def change
    add_column :geo_states, :abr_online_req_url, :string
    add_column :geo_states, :leo_lookup_url, :string
    add_column :geo_states, :abr_status_check_url, :string
    add_column :geo_states, :abr_track_ballot_url, :string
    add_column :geo_states, :abr_pdf_enabled, :boolean
  end
end
