class AddPdfDownloadedToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :pdf_downloaded, :boolean, :default=>false
  end
end
