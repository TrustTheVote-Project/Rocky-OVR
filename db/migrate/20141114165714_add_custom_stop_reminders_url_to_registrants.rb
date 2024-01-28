class AddCustomStopRemindersUrlToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :custom_stop_reminders_url, :string
  end
end
