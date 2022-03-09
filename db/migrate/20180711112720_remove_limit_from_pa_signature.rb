class RemoveLimitFromPaSignature < ActiveRecord::Migration[4.2]
  def up
    change_column :state_registrants_pa_registrants, :voter_signature_image, :text, :limit => nil
  end

  def down
    change_column :state_registrants_pa_registrants, :voter_signature_image, :text, :limit => 255
  end
end
