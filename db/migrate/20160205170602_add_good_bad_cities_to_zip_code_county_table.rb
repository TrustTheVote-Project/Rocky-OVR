class AddGoodBadCitiesToZipCodeCountyTable < ActiveRecord::Migration[4.2]
  def change
    add_column :zip_code_county_addresses, :cities, :text
    add_column :zip_code_county_addresses, :unacceptable_cities, :text
  end
end
