class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.string :email_address
      t.boolean :blacklisted
      t.timestamps null: false
    end
    add_index :email_addresses, :blacklisted
    add_index :email_addresses, :email_address
    add_index :email_addresses, [:blacklisted, :email_address]
    
  end
end
