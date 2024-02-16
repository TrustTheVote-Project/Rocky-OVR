class AddEmailInstructionsToStateLocalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :state_localizations, :email_instructions, :string
  end
end
