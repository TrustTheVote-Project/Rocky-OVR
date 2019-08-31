class UpdateReportDataColumn < ActiveRecord::Migration
  def change
    rename_column :reports, :data, :filters
  end
end
