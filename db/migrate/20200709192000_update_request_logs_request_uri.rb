class UpdateRequestLogsRequestUri < ActiveRecord::Migration[4.2]
  def change
    change_column :request_logs, :request_uri, :text
    change_column :request_logs, :request_headers, :text
  end
end
