class AddPdfInstructionsToStateLocalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :state_localizations, :pdf_instructions, :string
  end
end
