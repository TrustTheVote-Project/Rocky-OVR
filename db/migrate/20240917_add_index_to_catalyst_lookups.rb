class AddIndexToCatalystLookups < ActiveRecord::Migration[4.2]
  def up
    add_index :catalist_lookups, :uid
  end

  def down
    remove_index :catalist_lookups, :uid
  end
end
