class AddTrackingToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :tracking_source, :string
    add_column :abrs, :tracking_id, :string
  end
end
