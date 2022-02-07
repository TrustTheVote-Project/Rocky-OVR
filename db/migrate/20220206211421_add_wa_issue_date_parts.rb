class AddWaIssueDateParts < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_wa_registrants, :issue_date_mm,  :integer 
    add_column :state_registrants_wa_registrants, :issue_date_dd,  :integer 
    add_column :state_registrants_wa_registrants, :issue_date_yyyy,  :integer 
  end
end
