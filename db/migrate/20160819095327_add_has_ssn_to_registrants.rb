class AddHasSsnToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :has_ssn, :boolean
  end
end
