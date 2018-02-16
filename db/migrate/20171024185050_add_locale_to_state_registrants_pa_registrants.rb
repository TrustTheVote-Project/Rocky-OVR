class AddLocaleToStateRegistrantsPaRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :locale, :string
  end
end
