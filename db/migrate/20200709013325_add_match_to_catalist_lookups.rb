class AddMatchToCatalistLookups < ActiveRecord::Migration
  def change
    add_column :catalist_lookups, :match, :text
  end
end
