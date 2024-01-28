class AddHasMailingAddressAndConfirmRegisterToVoteToStateRegistrantsVaRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_va_registrants, :has_mailing_address, :boolean
    add_column :state_registrants_va_registrants, :confirm_register_to_vote, :boolean
  end
end
