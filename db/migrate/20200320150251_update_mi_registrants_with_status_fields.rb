class UpdateMiRegistrantsWithStatusFields < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_mi_registrants, :mi_api_voter_status_id, :string
  end
end
