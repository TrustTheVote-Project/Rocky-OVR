class AddPartnerSmsFieldsAndReset < ActiveRecord::Migration
  def change
    add_column :partners, :short_code, :string
    add_column :partners, :terms_url, :string
    Partner.update_all(partner_sms_opt_in: false)
  end
end
