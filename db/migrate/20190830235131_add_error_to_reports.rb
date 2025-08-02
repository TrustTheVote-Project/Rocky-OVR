class AddErrorToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :error, :text
  end
end
