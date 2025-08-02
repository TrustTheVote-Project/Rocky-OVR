class AddHasMailingAddressToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :has_mailing_address, :boolean
  end
end
