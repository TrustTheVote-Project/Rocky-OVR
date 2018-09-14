class CreatePdfDeliveries < ActiveRecord::Migration
  def change
    create_table :pdf_deliveries do |t|
      t.integer :registrant_id
      t.integer :delivery_attempts
      t.boolean :deliverd_to_printer
      t.boolean :pdf_ready
      
      t.timestamps null: false
    end
    add_index :pdf_deliveries, :registrant_id
    
  end
end
