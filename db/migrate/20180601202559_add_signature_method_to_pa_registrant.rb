class AddSignatureMethodToPaRegistrant < ActiveRecord::Migration[4.2]
  def change
    add_column :state_registrants_pa_registrants, :signature_method, :string
  end
end
