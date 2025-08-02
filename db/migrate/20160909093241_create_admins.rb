class CreateAdmins < ActiveRecord::Migration[4.2]
  def change
    create_table :admins do |t|
      t.string :username
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.timestamps
    end
  end
end
