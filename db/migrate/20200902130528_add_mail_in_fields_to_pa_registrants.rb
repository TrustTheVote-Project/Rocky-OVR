class AddMailInFieldsToPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :request_abr, :boolean
    add_column :state_registrants_pa_registrants, :abr_address_type, :string
    add_column :state_registrants_pa_registrants, :abr_ballot_address, :string
    add_column :state_registrants_pa_registrants, :abr_ballot_city, :string
    add_column :state_registrants_pa_registrants, :abr_ballot_state, :integer
    add_column :state_registrants_pa_registrants, :abr_ballot_zip, :string
    add_column :state_registrants_pa_registrants, :abr_ballot_address_start_year, :string
    add_column :state_registrants_pa_registrants, :abr_ward, :string
    add_column :state_registrants_pa_registrants, :abr_declaration, :string
  end
end
