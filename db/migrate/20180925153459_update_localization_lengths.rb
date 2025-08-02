class UpdateLocalizationLengths < ActiveRecord::Migration[4.2]
  def change
    
    change_column :state_localizations, :parties, :text,                   limit: 20480
    change_column :state_localizations, :not_participating_tooltip, :text, limit: 20480
    change_column :state_localizations, :race_tooltip, :text,              limit: 20480
    change_column :state_localizations, :id_number_tooltip, :text,         limit: 20480
    change_column :state_localizations, :party_tooltip, :text,             limit: 20480
    change_column :state_localizations, :sub_18, :text,                    limit: 20480
    change_column :state_localizations, :registration_deadline, :text,     limit: 20480
    change_column :state_localizations, :pdf_instructions, :text,          limit: 20480
    change_column :state_localizations, :email_instructions, :text,        limit: 20480
    change_column :state_localizations, :pdf_other_instructions, :text,    limit: 20480
    
    
  end
end
