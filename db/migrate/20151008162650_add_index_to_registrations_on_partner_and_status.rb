class AddIndexToRegistrationsOnPartnerAndStatus < ActiveRecord::Migration[4.2]
  def change
    add_index :registrants, [:partner_id, :status], name: :index_registrants_by_partner_and_status    
  end
end
