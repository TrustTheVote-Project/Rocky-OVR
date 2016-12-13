class AddExternalConversionSnippetToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :external_conversion_snippet, :text
  end
end
