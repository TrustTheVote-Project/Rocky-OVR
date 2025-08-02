class CreateRegistrantStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :registrant_statuses do |t|
      t.belongs_to :registrant
      t.string :state_transaction_id
      t.string :state_status
      t.string :state_status_details
      t.belongs_to :geo_state
      t.datetime :state_application_date
      t.text :state_data
      t.belongs_to :admin
      t.timestamps
    end
    
    add_index :registrant_statuses, [:state_transaction_id, :geo_state_id], name: :registrant_statues_state_id_index
    
  end
end
