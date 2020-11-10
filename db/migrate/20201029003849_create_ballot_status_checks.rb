class CreateBallotStatusChecks < ActiveRecord::Migration
  def change
    create_table :ballot_status_checks do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :zip
      t.string :phone

      t.integer :partner_id

      t.string   "tracking_source"
      t.string   "tracking_id"
      t.string   "uid"
      t.boolean  "opt_in_email"
      t.boolean  "opt_in_sms"
      t.boolean  "partner_opt_in_email"
      t.boolean  "partner_opt_in_sms"

      t.timestamps null: false
    end
    add_index :ballot_status_checks, :partner_id, name: :bsc_partners
    add_index :ballot_status_checks, :uid
  end
end
