class AddEnabledForCatalistApiToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :enabled_for_catalist_api, :boolean
  end
end
