class AddLastCheckedToZipCodeCountyAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :zip_code_county_addresses, :last_checked, :datetime
  end
end
