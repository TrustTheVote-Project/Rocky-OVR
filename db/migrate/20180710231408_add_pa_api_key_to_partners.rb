class AddPaApiKeyToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :pa_api_key, :string
  end
end
