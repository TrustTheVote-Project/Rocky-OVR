class AddAbrIdToRequestLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :request_logs, :abr_id, :string, index: true
  end
end
