class AddContinueOnDeviceMethodsToPaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :sms_number_for_continue_on_device, :string
    add_column :state_registrants_pa_registrants, :email_address_for_continue_on_device, :string
  end
end
