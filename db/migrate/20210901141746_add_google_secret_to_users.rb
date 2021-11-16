class AddGoogleSecretToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :google_secret, :string
  end
end
