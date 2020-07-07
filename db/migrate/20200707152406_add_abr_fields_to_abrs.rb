class AddAbrFieldsToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :state_id, :string
    add_column :abrs, :party, :string
    add_column :abrs, :add_to_permanent_early_voting_list, :boolean    
  end
end
