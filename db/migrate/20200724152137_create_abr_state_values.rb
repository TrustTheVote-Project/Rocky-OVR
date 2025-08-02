class CreateAbrStateValues < ActiveRecord::Migration[4.2]
  def change
    create_table :abr_state_values do |t|
      t.integer :abr_id, index: true
      t.string :attribute_name, index: true
      t.string :string_value
      t.timestamps null: false
    end
  end
end
