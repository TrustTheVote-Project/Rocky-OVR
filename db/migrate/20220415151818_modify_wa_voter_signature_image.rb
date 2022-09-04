class ModifyWaVoterSignatureImage < ActiveRecord::Migration[5.2]
  def self.up
    change_table :state_registrants_wa_registrants do |t|
      t.change :voter_signature_image, :text
    end
  end
  def self.down
    change_table :state_registrants_wa_registrants do |t|
      t.change :voter_signature_image, :string
    end
  end
end
