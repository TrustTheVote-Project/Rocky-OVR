class AddMainPhoneEmailToZipCodeCountyAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :zip_code_county_addresses, :vr_main_phone, :string
    add_column :zip_code_county_addresses, :vr_main_email, :string
    add_column :zip_code_county_addresses, :req_main_phone, :string
    add_column :zip_code_county_addresses, :req_main_email, :string
    
  end
end
