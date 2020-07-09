class AddEnabledForCatalistApiToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :enabled_for_catalist_api, :boolean
  end
end
