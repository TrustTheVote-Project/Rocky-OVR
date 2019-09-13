class AddErrorToReports < ActiveRecord::Migration
  def change
    add_column :reports, :error, :text
  end
end
