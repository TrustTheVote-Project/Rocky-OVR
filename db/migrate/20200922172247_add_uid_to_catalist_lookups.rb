class AddUidToCatalistLookups < ActiveRecord::Migration[4.2]
  def change
    add_column :catalist_lookups, :uid, :string, index: true
  end
end
