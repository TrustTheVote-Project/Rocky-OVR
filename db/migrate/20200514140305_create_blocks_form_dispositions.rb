class CreateBlocksFormDispositions < ActiveRecord::Migration
  def change
    create_table :blocks_form_dispositions do |t|
      t.integer :grommet_request_id, index: true
      t.string :registrant_id, index: true
      t.integer :blocks_form_id, index: true
      t.boolean :final_state_submitted, default: false
      t.timestamps null: false
    end
  end
end
