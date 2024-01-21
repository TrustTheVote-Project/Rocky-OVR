class AddRemotePdfPathToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :remote_pdf_path, :string
  end
end
