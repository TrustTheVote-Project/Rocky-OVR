class AddRegistrationCountyToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :registration_county, :string
  end
end
