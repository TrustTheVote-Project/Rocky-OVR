class ChangeZipCodeCountyToArray < ActiveRecord::Migration[4.2]
  def up
    change_column :zip_code_county_addresses, :county, :text
  end

  def down
    change_column :zip_code_county_addresses, :county, :string
  end
end
