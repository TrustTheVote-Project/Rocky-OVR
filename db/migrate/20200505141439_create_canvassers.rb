class CreateCanvassers < ActiveRecord::Migration
  def change
    create_table :canvassers do |t|
      t.string :canvasser_external_id
      t.string :name
      t.string :phone
      
      t.timestamps null: false
    end
    add_index :canvassers, :canvasser_external_id
  end
end
