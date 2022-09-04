class AddAbrIdToVoterSignatures < ActiveRecord::Migration[4.2]
  def change
    add_column :voter_signatures, :abr_id, :integer, index: true
  end
end
