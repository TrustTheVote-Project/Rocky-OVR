class ChangeZipCodeCountyToArray < ActiveRecord::Migration
  def up
    change_column :zip_code_county_addresses, :county, :text
  end

  def down
    change_column :zip_code_county_addresses, :county, :string
  end
end
