class AddRemoteUidToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :remote_uid, :string
    add_index :registrants, :remote_uid
  end
end
