class AddRegistrationInstructionsUrlToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :registration_instructions_url, :string
  end
end
