class AddEnabledForGrommetToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :enabled_for_grommet, :boolean, null: false, default: false
  end
end
