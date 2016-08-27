class AddPdfOtherInstructionsToStateLocalizations < ActiveRecord::Migration
  def change
    add_column :state_localizations, :pdf_other_instructions, :string, :limit => 1024
  end
end
