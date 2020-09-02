class CreateAbrsCatalistLookups < ActiveRecord::Migration
  def change
    create_table :abrs_catalist_lookups do |t|
      t.integer :abr_id, index: true
      t.integer :catalist_lookup_id, index: true

      t.timestamps null: false
    end
    add_index :abrs_catalist_lookups, [:abr_id, :catalist_lookup_id], name: :abrs_catalist_join_index
  end
end
