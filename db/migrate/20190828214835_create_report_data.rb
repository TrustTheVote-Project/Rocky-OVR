class CreateReportData < ActiveRecord::Migration
  def change
    create_table :report_data do |t|
      t.integer :report_id
      t.string :key
      t.string :s_value
      t.integer :i_value
      t.timestamps null: false
    end
    add_index :report_data, :report_id
    add_index :report_data, :key
    add_index :report_data, [:report_id, :key]
    
  end
end
