class AddAbrIdToVoterSignatures < ActiveRecord::Migration
  def change
    add_column :voter_signatures, :abr_id, :integer, index: true
  end
end
