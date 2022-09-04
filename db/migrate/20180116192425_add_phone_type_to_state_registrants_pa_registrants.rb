class AddPhoneTypeToStateRegistrantsPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :phone_type, :string
  end
end
