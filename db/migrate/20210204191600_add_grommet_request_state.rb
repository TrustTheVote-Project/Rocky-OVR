class AddGrommetRequestState < ActiveRecord::Migration[4.2]
  def up
    add_column :grommet_requests, :state, :string
    GrommetRequest.update_all(state: "PA")
  end
  
  def down
    remove_column :grommet_requests, :state
  end
end