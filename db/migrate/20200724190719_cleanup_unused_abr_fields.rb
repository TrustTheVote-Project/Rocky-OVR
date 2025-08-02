class CleanupUnusedAbrFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :abrs, :gender
    remove_column :abrs, :mailing_address
    remove_column :abrs, :mailing_city
    remove_column :abrs, :mailing_state_id
    remove_column :abrs, :mailing_zip_code
    remove_column :abrs, :state_id_number
    remove_column :abrs, :party
    remove_column :abrs, :add_to_permanent_early_voting_list
    remove_column :abrs, :has_mailing_address
  end
end
