class CreateVoterSignatures < ActiveRecord::Migration
  def change
    create_table :voter_signatures do |t|
      t.string :registrant_id, index: true
      t.text   :voter_signature_image
      t.string :signature_method
      t.string :sms_number_for_continue_on_device
      t.string :email_address_for_continue_on_device
      
      t.timestamps null: false
    end
  end
end
