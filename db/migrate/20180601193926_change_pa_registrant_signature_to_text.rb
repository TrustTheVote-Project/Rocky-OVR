class ChangePaRegistrantSignatureToText < ActiveRecord::Migration[4.2]
  def up
    change_column :state_registrants_pa_registrants, :voter_signature_image, :text    
  end

  def down
    change_column :state_registrants_pa_registrants, :voter_signature_image, :string    
  end
end
