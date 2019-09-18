class AddHashToReportData < ActiveRecord::Migration
  def change
    add_column :report_data, :h_value, :text
  end
end
