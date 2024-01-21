class AddConfirmEmailDeliveryToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :confirm_email_delivery, :boolean
  end
end
