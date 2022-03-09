class ChangeParterAskForVolunteersDefaultToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column_default :partners, :ask_for_volunteers, false
  end

  def down
    change_column_default :partners, :ask_for_volunteers, true
  end
end
