class AddRegistrantUidToAbrs < ActiveRecord::Migration[5.2]
  def change
    add_column :abrs, :registrant_uid, :string
  end
end
