class AddTrackingToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :tracking_source, :string
    add_column :abrs, :tracking_id, :string
  end
end
