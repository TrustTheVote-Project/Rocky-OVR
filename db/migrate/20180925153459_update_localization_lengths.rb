class UpdateLocalizationLengths < ActiveRecord::Migration
  def change
    
    change_column :state_localizations, :parties, :string,                   limit: 20480
    change_column :state_localizations, :not_participating_tooltip, :string, limit: 20480
    change_column :state_localizations, :race_tooltip, :string,              limit: 20480
    change_column :state_localizations, :id_number_tooltip, :string,         limit: 20480
    change_column :state_localizations, :party_tooltip, :string,             limit: 20480
    change_column :state_localizations, :sub_18, :string,                    limit: 20480
    change_column :state_localizations, :registration_deadline, :string,     limit: 20480
    change_column :state_localizations, :pdf_instructions, :string,          limit: 20480
    change_column :state_localizations, :email_instructions, :string,        limit: 20480
    change_column :state_localizations, :pdf_other_instructions, :string,    limit: 20480
    
    
  end
end
