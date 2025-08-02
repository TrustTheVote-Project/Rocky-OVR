class AddMailingAddressToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :mailing_address, :string
    add_column :abrs, :mailing_city, :string
    add_column :abrs, :mailing_state_id, :integer, index: true
    add_column :abrs, :mailing_zip_code, :string
  end
end
