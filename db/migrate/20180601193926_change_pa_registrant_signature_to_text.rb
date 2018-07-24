class ChangePaRegistrantSignatureToText < ActiveRecord::Migration
  def up
    change_column :state_registrants_pa_registrants, :voter_signature_image, :text    
  end

  def down
    change_column :state_registrants_pa_registrants, :voter_signature_image, :string    
  end
end
