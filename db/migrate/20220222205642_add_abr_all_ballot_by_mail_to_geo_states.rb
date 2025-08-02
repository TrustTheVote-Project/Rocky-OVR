class AddAbrAllBallotByMailToGeoStates < ActiveRecord::Migration[5.2]
  def change
    add_column :geo_states, :abr_all_ballot_by_mail, :boolean
  end
end
