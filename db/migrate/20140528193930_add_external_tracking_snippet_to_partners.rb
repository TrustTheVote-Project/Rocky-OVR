class AddExternalTrackingSnippetToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :external_tracking_snippet, :text
  end
end
