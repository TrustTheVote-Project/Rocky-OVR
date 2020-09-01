class UpdateRequestLogsRequestUri < ActiveRecord::Migration
  def change
    change_column :request_logs, :request_uri, :text
    change_column :request_logs, :request_headers, :text
  end
end
