class AddVotercheckToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :votercheck, :string
  end
end
