class AddContactInfoToZipCodeCountyAddresses < ActiveRecord::Migration
  def change
    add_column :zip_code_county_addresses, :vr_contact_office_name, :string
    add_column :zip_code_county_addresses, :vr_contact_title, :string
    add_column :zip_code_county_addresses, :vr_contact_first_name, :string
    add_column :zip_code_county_addresses, :vr_contact_last_name, :string
    add_column :zip_code_county_addresses, :vr_contact_suffix, :string
    add_column :zip_code_county_addresses, :vr_website, :string

    add_column :zip_code_county_addresses, :req_contact_office_name, :string
    add_column :zip_code_county_addresses, :req_contact_title, :string
    add_column :zip_code_county_addresses, :req_contact_first_name, :string
    add_column :zip_code_county_addresses, :req_contact_last_name, :string
    add_column :zip_code_county_addresses, :req_contact_suffix, :string
    add_column :zip_code_county_addresses, :req_website, :string
end
end
