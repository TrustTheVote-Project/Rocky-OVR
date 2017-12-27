class AddNoUspsAddressToStateRegistrantsVaRegistrants < ActiveRecord::Migration
  def change
    add_column 'state_registrants_va_registrants', "no_usps_address", :boolean
  end
end
