class AddActiveToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :active, :boolean, default: true, null: false
  end
end
