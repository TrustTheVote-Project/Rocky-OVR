class AddHasMailingAddressToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :has_mailing_address, :boolean
  end
end
