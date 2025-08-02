class AddPdfOtherInstructionsToStateLocalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :state_localizations, :pdf_other_instructions, :string, :limit => 1024
  end
end
