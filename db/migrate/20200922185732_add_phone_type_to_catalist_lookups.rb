class AddPhoneTypeToCatalistLookups < ActiveRecord::Migration
  def change
    add_column :catalist_lookups, :phone_type, :string
  end
end
