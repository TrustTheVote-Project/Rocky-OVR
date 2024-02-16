class AddFailedLoginCountToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :failed_login_count, :integer
  end
end
