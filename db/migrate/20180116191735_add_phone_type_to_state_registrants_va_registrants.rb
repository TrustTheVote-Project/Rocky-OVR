class AddPhoneTypeToStateRegistrantsVaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_va_registrants, :phone_type, :string
  end
end
