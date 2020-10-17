class CreateCatalistLookupsRegistrants < ActiveRecord::Migration
  def change
    create_table :catalist_lookups_registrants do |t|
      t.string :registrant_uid, index: true
      t.integer :catalist_lookup_id, index: true

      t.timestamps null: false
    end
    add_index :catalist_lookups_registrants, [:registrant_uid, :catalist_lookup_id], name: :registrants_catalist_join_index
  end
end
