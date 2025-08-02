class AddRequestHeadersToGrommetRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :grommet_requests, :request_headers, :text
  end
end
