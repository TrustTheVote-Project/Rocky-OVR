class AddHashToReportData < ActiveRecord::Migration[4.2]
  def change
    add_column :report_data, :h_value, :text
  end
end
