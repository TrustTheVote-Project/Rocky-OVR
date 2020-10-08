class AddPartnerIdAndTrackingToCatalistLookups < ActiveRecord::Migration
  def change
    add_column :catalist_lookups, :partner_id, :integer
    add_column :catalist_lookups, :tracking_source, :string
    add_column :catalist_lookups, :tracking_id, :string
    add_index :catalist_lookups, :partner_id
  end
end
