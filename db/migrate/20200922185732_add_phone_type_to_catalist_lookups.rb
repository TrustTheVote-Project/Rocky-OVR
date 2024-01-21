class AddPhoneTypeToCatalistLookups < ActiveRecord::Migration[4.2]
  def change
    add_column :catalist_lookups, :phone_type, :string
  end
end
