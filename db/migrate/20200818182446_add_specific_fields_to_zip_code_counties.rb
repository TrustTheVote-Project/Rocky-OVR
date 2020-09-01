class AddSpecificFieldsToZipCodeCounties < ActiveRecord::Migration
  def change
    add_column :zip_code_county_addresses, :vr_address_to, :string
    add_column :zip_code_county_addresses, :vr_street1, :string
    add_column :zip_code_county_addresses, :vr_street2, :string
    add_column :zip_code_county_addresses, :vr_city, :string
    add_column :zip_code_county_addresses, :vr_state, :string
    add_column :zip_code_county_addresses, :vr_zip, :string


    add_column :zip_code_county_addresses, :req_address_to, :string
    add_column :zip_code_county_addresses, :req_street1, :string
    add_column :zip_code_county_addresses, :req_street2, :string
    add_column :zip_code_county_addresses, :req_city, :string
    add_column :zip_code_county_addresses, :req_state, :string
    add_column :zip_code_county_addresses, :req_zip, :string
      
  end
end
