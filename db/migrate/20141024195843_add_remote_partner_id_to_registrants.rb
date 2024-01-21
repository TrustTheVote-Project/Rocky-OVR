class AddRemotePartnerIdToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :remote_partner_id, :integer
    add_index :registrants, :remote_partner_id
  end
end
