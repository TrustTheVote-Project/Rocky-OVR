class AddGoogleSecretToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :google_secret, :string
  end
end
