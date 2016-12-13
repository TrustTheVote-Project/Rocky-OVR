class AddReplaceSystemCssToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :replace_system_css, :text
  end
end
