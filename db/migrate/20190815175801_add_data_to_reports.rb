class AddDataToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :data, :text
  end
end
