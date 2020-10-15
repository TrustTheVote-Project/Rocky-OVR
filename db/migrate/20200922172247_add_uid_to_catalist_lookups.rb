class AddUidToCatalistLookups < ActiveRecord::Migration
  def change
    add_column :catalist_lookups, :uid, :string, index: true
  end
end
