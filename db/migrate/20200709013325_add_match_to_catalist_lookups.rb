class AddMatchToCatalistLookups < ActiveRecord::Migration[4.2]
  def change
    add_column :catalist_lookups, :match, :text
  end
end
