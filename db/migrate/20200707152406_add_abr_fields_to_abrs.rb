class AddAbrFieldsToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :state_id_number, :string
    add_column :abrs, :party, :string
    add_column :abrs, :phone_type, :string
    add_column :abrs, :add_to_permanent_early_voting_list, :boolean    
    
    add_column :abrs, :opt_in_email, :boolean
    add_column :abrs, :opt_in_sms, :boolean
    add_column :abrs, :partner_opt_in_email, :boolean
    add_column :abrs, :partner_opt_in_sms, :boolean
  end
end
