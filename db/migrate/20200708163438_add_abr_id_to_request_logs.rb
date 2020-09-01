class AddAbrIdToRequestLogs < ActiveRecord::Migration
  def change
    add_column :request_logs, :abr_id, :string, index: true
  end
end
