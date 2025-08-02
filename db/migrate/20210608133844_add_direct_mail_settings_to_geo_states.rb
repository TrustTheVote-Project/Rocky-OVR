class AddDirectMailSettingsToGeoStates <  ActiveRecord::Migration[4.2]
  def change
    add_column :geo_states, :enable_direct_mail, :boolean, default: false
    add_column :geo_states, :allow_desktop_signature, :boolean, default: false
    add_column :geo_states, :direct_mail_partner_ids, :text
    add_column :geo_states, :state_voter_check_url, :string
  end
end
