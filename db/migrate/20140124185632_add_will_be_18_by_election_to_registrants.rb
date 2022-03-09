class AddWillBe18ByElectionToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :will_be_18_by_election, :boolean
  end
end
