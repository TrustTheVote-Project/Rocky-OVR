class AddGovernmentPartnerZipCodesToPartners < ActiveRecord::Migration[4.2]
  def self.up
    add_column :partners, :government_partner_zip_codes, :text
  end

  def self.down
    remove_column :partners, :government_partner_zip_codes
  end
end
