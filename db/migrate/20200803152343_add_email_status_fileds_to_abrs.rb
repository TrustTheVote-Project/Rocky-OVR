class AddEmailStatusFiledsToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :final_reminder_delivered, :boolean, default: false
    add_column :abrs, :reminders_left, :integer
  end
end
