class AddHasFieldsToMiRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_mi_registrants, :has_ssn, :boolean, default: false
    add_column :state_registrants_mi_registrants, :has_state_license, :boolean, default: false
  end
end
