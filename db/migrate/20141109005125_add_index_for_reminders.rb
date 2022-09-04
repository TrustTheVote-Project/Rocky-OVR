class AddIndexForReminders < ActiveRecord::Migration[4.2]
  def up
    add_index :registrants, [:reminders_left, :updated_at]
  end

  def down
    remove_index :registrants, [:reminders_left, :updated_at]
  end
end
