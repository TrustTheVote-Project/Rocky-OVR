class AddFailedLoginCountToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :failed_login_count, :integer
  end
end
