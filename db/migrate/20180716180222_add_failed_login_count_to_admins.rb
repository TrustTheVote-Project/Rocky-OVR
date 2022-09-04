class AddFailedLoginCountToAdmins < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :failed_login_count, :integer
  end
end
