class AddPhoneTypeToStateRegistrantsPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :phone_type, :string
  end
end
