class CreateEmailDomains < ActiveRecord::Migration[4.2]
  def change
    create_table :email_domains do |t|
      t.string :domain
      t.boolean :blacklisted

      t.timestamps null: false
    end
    add_index :email_domains, :blacklisted
    add_index :email_domains, :domain
    add_index :email_domains, [:blacklisted, :domain]
    
  end
end
