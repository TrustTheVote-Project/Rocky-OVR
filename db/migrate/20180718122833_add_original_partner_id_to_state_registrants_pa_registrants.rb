class AddOriginalPartnerIdToStateRegistrantsPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :original_partner_id, :integer
    add_index :state_registrants_pa_registrants, :original_partner_id, name: :pa_registrants_original_partner_id
  end
end
