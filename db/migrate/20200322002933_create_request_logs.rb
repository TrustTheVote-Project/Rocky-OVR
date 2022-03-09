class CreateRequestLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :request_logs do |t|
      t.string :client_id, index: true
      t.string :registrant_id, index: true
      t.string :request_uri
      t.text :request_body
      t.string :request_headers
      t.integer :response_code, index: true
      t.text :response_body
      t.text :error_messages
      t.integer :network_duration_ms
      t.integer :total_duration_ms


      t.timestamps null: false
    end
  end
end
