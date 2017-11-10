class AddRegistrantIdToPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :registrant_id, :string, index: true
  end
end
