class AddFromEmailVerifiedAtToPartner < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :from_email_verified_at, :datetime
    add_column :partners, :from_email_verification_checked_at, :datetime
  end
end
