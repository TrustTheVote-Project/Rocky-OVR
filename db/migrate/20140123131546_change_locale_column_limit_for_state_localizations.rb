class ChangeLocaleColumnLimitForStateLocalizations < ActiveRecord::Migration[4.2]
  def up
    change_column :state_localizations, :locale, :string, :limit => 64
  end

  def down
    change_column :state_localizations, :locale, :string, :limit => 2
  end
end
