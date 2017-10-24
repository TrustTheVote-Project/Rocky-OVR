class AddRegistrantIdToPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :registrant_id, :integer, index: true
  end
end
