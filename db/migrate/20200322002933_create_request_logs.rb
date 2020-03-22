class CreateRequestLogs < ActiveRecord::Migration
  def change
    create_table :request_logs do |t|
      t.string :client_id
      t.string :registrant_id
      t.string :request_host
      t.string :request_path
      t.text :request_body
      t.string :request_headers
      t.integer :response_code
      t.text :response_body
      t.string :error_class
      t.text :error_message
      t.integer :duration_ms


      t.timestamps null: false
    end
  end
end
