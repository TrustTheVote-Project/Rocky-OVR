class AddPaApiKeyToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :pa_api_key, :string
  end
end
