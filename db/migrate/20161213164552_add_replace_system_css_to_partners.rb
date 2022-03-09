class AddReplaceSystemCssToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :replace_system_css, :text
  end
end
