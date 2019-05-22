class CreateAbTests < ActiveRecord::Migration
  def change
    create_table :ab_tests do |t|
      t.integer :registrant_id
      t.string :name
      t.string :assignment
      t.timestamps null: false
    end
    add_index :ab_tests, :registrant_id
    add_index :ab_tests, :name
    add_index :ab_tests, [:name, :assigment]
  end
end
