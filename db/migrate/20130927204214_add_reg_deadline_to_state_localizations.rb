class AddRegDeadlineToStateLocalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :state_localizations, :registration_deadline, :string
  end
end
