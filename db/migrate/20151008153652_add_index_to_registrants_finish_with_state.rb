class AddIndexToRegistrantsFinishWithState < ActiveRecord::Migration[4.2]
  def change
    add_index :registrants, [:finish_with_state, :partner_id, :status, :created_at], name: :index_registrants_for_stats
  end
end
