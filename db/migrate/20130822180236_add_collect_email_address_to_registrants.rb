class AddCollectEmailAddressToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :collect_email_address, :string
  end
end
