class AddStateOvrDataToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :state_ovr_data, :text
  end
end
