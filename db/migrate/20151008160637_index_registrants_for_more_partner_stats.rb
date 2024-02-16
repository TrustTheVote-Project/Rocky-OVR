class IndexRegistrantsForMorePartnerStats < ActiveRecord::Migration[4.2]
  def change
    add_index :registrants, [:finish_with_state, :partner_id, :status], name: :index_registrants_for_started_count
    add_index :registrants, [:finish_with_state, :partner_id, :status, :home_state_id], name: :index_registrants_by_state
    add_index :registrants, [:status, :partner_id, :race], name: :index_registrants_by_race
    add_index :registrants, [:status, :partner_id, :name_title], name: :index_registrants_by_gender
    add_index :registrants, [:status, :partner_id, :age], name: :index_registrants_by_age
    add_index :registrants, [:status, :partner_id, :official_party_name], name: :index_registrants_by_party
  end
end
