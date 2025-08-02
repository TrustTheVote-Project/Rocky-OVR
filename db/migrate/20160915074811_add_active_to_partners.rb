class AddActiveToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :active, :boolean, default: true, null: false
  end
end
