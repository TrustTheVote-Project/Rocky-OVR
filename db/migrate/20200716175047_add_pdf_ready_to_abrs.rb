class AddPdfReadyToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :pdf_ready, :boolean
    add_column :abrs, :pdf_downloaded, :boolean
    add_column :abrs, :pdf_downloaded_at, :datetime
  end
end
