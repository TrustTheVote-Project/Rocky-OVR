class AddStatesEnabledForPdfAssistanceToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :states_enabled_for_pdf_assistance, :text
  end
end
