class AddSignatureMethodToPaRegistrant < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, :signature_method, :string
  end
end
