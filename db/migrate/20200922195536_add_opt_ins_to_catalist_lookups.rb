class AddOptInsToCatalistLookups < ActiveRecord::Migration
  def change
    add_column "catalist_lookups", "opt_in_email", :boolean
    add_column "catalist_lookups", "opt_in_sms", :boolean
    add_column "catalist_lookups", "partner_opt_in_email", :boolean
    add_column "catalist_lookups", "partner_opt_in_sms", :boolean
    
  end
end
