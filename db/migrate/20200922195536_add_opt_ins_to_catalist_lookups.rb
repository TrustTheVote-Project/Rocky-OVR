class AddOptInsToCatalistLookups < ActiveRecord::Migration[4.2]
  def change
    add_column "catalist_lookups", "opt_in_email", :boolean
    add_column "catalist_lookups", "opt_in_sms", :boolean
    add_column "catalist_lookups", "partner_opt_in_email", :boolean
    add_column "catalist_lookups", "partner_opt_in_sms", :boolean
    
  end
end
