class AddPenndotRetriesToStateRegistrantsPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :penndot_retries, :integer, default: 0
  end
end
