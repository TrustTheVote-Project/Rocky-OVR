class AddIndexToRegistrationsOnPartnerAndStatus < ActiveRecord::Migration
  def change
    add_index :registrants, [:status, :partner_id], name: :index_registrants_by_partner_and_status    
  end
end
