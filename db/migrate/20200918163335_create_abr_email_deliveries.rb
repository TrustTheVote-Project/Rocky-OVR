class CreateAbrEmailDeliveries < ActiveRecord::Migration
  def change
    create_table :abr_email_deliveries do |t|
      t.integer :abr_id, index: true
      t.string :to_email, index: true
      t.timestamps null: false
    end
  end
end
