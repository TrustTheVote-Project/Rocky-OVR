class AddPhonesAndEmailsToZipCodeCountyAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :zip_code_county_addresses, :vr_contact_email, :string
    add_column :zip_code_county_addresses, :vr_contact_phone, :string
    add_column :zip_code_county_addresses, :req_contact_email, :string
    add_column :zip_code_county_addresses, :req_contact_phone, :string
  end
end
