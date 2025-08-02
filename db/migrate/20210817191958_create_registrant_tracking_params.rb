class CreateRegistrantTrackingParams < ActiveRecord::Migration[5.2]
  def change
    create_table :registrant_tracking_params do |t|
      t.belongs_to :registrant
      t.string :name
      t.string :value
      t.timestamps
    end
  end
end
