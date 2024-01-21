class AddRegistrantIdToPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :registrant_id, :string, index: true
  end
end
