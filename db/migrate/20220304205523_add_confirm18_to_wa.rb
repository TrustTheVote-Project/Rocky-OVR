class AddConfirm18ToWa < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_wa_registrants, :confirm_will_be_18,  :boolean 
  end
end
