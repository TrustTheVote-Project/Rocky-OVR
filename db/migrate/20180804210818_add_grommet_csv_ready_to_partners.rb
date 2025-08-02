class AddGrommetCsvReadyToPartners < ActiveRecord::Migration[4.2]
  def change
    add_column :partners, :grommet_csv_ready, :boolean
    add_column :partners, :grommet_csv_file_name, :string
  end
end
