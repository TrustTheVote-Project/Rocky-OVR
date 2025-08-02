class UpdateReportDataColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :reports, :data, :filters
  end
end
