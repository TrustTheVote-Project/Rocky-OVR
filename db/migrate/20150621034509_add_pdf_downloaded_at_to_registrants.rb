class AddPdfDownloadedAtToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :pdf_downloaded_at, :datetime
  end
end
