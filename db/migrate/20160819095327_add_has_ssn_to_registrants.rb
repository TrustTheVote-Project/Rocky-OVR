class AddHasSsnToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :has_ssn, :boolean
  end
end
