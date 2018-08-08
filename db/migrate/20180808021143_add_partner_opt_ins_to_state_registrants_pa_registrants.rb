class AddPartnerOptInsToStateRegistrantsPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :partner_opt_in_sms, :boolean
    add_column :state_registrants_pa_registrants, :partner_opt_in_email, :boolean
    add_column :state_registrants_pa_registrants, :partner_volunteer, :boolean
  end
end
