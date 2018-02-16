class AddStatusToStateRegistrantsPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :status, :string
  end
end
