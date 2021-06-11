class AddGrommetRequestIdToMiRegistrants < ActiveRecord::Migration
  def change
    add_column "state_registrants_mi_registrants", :grommet_request_id, :integer
    add_index :state_registrants_mi_registrants, :grommet_request_id, name: :mi_grommet_id
  end
end
