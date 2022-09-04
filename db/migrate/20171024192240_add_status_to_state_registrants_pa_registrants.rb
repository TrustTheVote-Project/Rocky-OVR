class AddStatusToStateRegistrantsPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :status, :string
  end
end
