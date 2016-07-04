class ExtentEmailInstructions < ActiveRecord::Migration
  def up
    change_column :state_localizations, :email_instructions,  :string, :limit => 2048
    change_column :state_localizations, :pdf_instructions,  :string, :limit => 2048
  end

  def down
    change_column :state_localizations, :email_instructions,  :string, :limit => 1024
    change_column :state_localizations, :pdf_instructions,  :string, :limit => 1024
  end
end
