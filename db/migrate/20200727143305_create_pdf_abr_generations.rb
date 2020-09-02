class CreatePdfAbrGenerations < ActiveRecord::Migration
  def change
    create_table :pdf_abr_generations do |t|
      t.integer :abr_id
      t.boolean :locked, :default=>false
      t.timestamps
    end
    add_index :pdf_abr_generations, :locked
  end
end
