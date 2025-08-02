class CreateAbrs < ActiveRecord::Migration[4.2]
  def change
    create_table :abrs do |t|
      t.string :uid, index: true
      t.integer :partner_id, index: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :name_suffix
      t.string :address
      t.string :city
      t.integer :home_state_id, index: true
      t.string :zip
      t.string :gender
      t.string :email, index: true
      t.string :phone
      t.date :date_of_birth
      
      t.boolean :javascript_disabled, default: false

      t.timestamps null: false
    end

  end
end
