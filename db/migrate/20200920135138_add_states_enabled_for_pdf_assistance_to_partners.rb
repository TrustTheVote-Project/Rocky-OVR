class AddStatesEnabledForPdfAssistanceToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :states_enabled_for_pdf_assistance, :text
  end
end
