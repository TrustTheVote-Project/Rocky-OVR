class AddFailedLoginCountToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :failed_login_count, :integer
  end
end
