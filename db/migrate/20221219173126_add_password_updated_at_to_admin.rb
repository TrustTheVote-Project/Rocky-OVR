class AddPasswordUpdatedAtToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :password_updated_at, :datetime
  end
end
