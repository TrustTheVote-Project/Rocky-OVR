class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string   :report_type
      t.integer  :record_count
      t.integer  :current_index
      t.integer  :partner_id
      t.string   :status
      t.timestamps null: false
    end
  end
end
