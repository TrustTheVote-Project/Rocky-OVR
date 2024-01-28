class AddRequestHashToGrommetRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :grommet_requests, :request_hash, :string
    add_index  :grommet_requests, :request_hash
  end
end
