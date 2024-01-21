class AddRegistrationCountyToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :registration_county, :string
  end
end
