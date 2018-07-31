class AddRequestHashToGrommetRequests < ActiveRecord::Migration
  def change
    add_column :grommet_requests, :request_hash, :string
    add_index  :grommet_requests, :request_hash
  end
end
