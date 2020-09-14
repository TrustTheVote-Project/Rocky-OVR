class AddConfirmEmailDeliveryToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :confirm_email_delivery, :boolean
  end
end
