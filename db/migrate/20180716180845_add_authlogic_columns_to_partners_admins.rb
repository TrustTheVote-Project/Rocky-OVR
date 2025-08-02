class AddAuthlogicColumnsToPartnersAdmins < ActiveRecord::Migration[4.2]
  def change
    add_index :admins, :persistence_token, unique: true

    add_column :admins, :perishable_token, :string
    add_index :admins, :perishable_token, unique: true
    
    add_column :admins, :login_count, :integer, default: 0, null: false
    add_column :admins, :last_request_at, :datetime
    add_column :admins, :current_login_at, :datetime
    add_column :admins, :last_login_at, :datetime
    add_column :admins, :current_login_ip, :string
    add_column :admins, :last_login_ip, :string

    
    add_column :partners, :login_count, :integer, default: 0, null: false
    add_column :partners, :last_request_at, :datetime
    add_column :partners, :current_login_at, :datetime
    add_column :partners, :last_login_at, :datetime
    add_column :partners, :current_login_ip, :string
    add_column :partners, :last_login_ip, :string
    
  end
end
