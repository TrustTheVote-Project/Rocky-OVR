class CreatePriorityPdfGenerations < ActiveRecord::Migration[4.2]
  def change
    create_table :priority_pdf_generations do |t|
      t.integer :registrant_id
      t.boolean :locked, :default=>false
      t.timestamps
    end
    add_index :priority_pdf_generations, :locked
  end
end
