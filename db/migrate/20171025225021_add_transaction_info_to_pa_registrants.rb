class AddTransactionInfoToPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :pa_submission_complete, :boolean
    add_column :state_registrants_pa_registrants, :pa_transaction_id, :string
    add_column :state_registrants_pa_registrants, :pa_submission_error, :text
  end
end
