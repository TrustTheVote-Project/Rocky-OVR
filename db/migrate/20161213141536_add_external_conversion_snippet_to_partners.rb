class AddExternalConversionSnippetToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :external_conversion_snippet, :text
  end
end
