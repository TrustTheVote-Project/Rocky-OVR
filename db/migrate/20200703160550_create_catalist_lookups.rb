class CreateCatalistLookups < ActiveRecord::Migration[4.2]
  def change
    create_table :catalist_lookups do |t|
      t.string :first
      t.string :middle
      t.string :last
      t.string :suffix
      t.string :gender
      t.date :birthdate
      t.string :address
      t.string :city
      t.integer :state_id, index: true
      t.string :zip
      t.string :county
      t.string :phone
      t.string :email, index: true

      t.timestamps null: false
    end
  end
end
