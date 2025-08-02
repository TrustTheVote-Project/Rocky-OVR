class AddMissingPartnerApiKeyToStateRegistrantsPaRegistrant < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_pa_registrants, :missing_partner_api_key, :boolean
  end
end
