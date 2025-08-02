class ModifyWaStateRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :state_registrants_wa_registrants, :voter_signature_image,  :string 
    add_column :state_registrants_wa_registrants, :signature_method, :string
    add_column :state_registrants_wa_registrants, :sms_number_for_continue_on_device, :string
    add_column :state_registrants_wa_registrants, :email_address_for_continue_on_device, :string

    remove_column :state_registrants_wa_registrants, :issue_date_mm, :integer
    remove_column :state_registrants_wa_registrants, :issue_date_dd, :integer
    remove_column :state_registrants_wa_registrants, :issue_date_yyyy, :integer
  end
end
