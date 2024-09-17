class AddIndexToCatalystLookups < ActiveRecord::Migration[4.2]
  def up
    add_index :catalyst_lookups, :uid
  end

  def down
    remove_index :catalyst_lookups, :uid
  end
end
