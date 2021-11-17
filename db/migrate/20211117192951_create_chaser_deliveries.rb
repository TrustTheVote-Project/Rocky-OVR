class CreateChaserDeliveries < ActiveRecord::Migration[5.2]
  def change
    create_table :chaser_deliveries do |t|
      t.string :email, index: true
      t.integer :abr_id, index: true
      t.integer :registrant_id, index: true
      t.timestamps
    end
  end
end
