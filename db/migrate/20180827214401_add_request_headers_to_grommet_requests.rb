class AddRequestHeadersToGrommetRequests < ActiveRecord::Migration
  def change
    add_column :grommet_requests, :request_headers, :text
  end
end
