class AddConfirmNoPenndotNumberToStateRegistrantsPaRegistrant < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :confirm_no_penndot_number, :boolean
  end
end
