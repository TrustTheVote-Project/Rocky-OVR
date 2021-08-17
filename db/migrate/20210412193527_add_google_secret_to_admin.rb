class AddGoogleSecretToAdmin < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :google_secret, :string
  end
end
