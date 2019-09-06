class CreateAbTests < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'ab_tests'
      create_table :ab_tests do |t|
        t.integer :registrant_id
        t.string :name
        t.string :assignment
        t.timestamps null: false
      end
    end
    add_index(:ab_tests, :registrant_id) unless ActiveRecord::Base.connection.index_exists?(:ab_tests, :registrant_id)
    add_index(:ab_tests, :name) unless  ActiveRecord::Base.connection.index_exists?(:ab_tests, :name) 
    add_index(:ab_tests, [:name, :assignment]) unless  ActiveRecord::Base.connection.index_exists?(:ab_tests, [:name, :assignment])
  end
end
