class AddPhoneTypeToStateRegistrantsVaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_va_registrants, :phone_type, :string
  end
end
