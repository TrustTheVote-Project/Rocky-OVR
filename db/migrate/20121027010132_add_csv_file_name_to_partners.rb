class AddCsvFileNameToPartners < ActiveRecord::Migration[4.2]
  def self.up
    add_column :partners, :csv_file_name, :string
  end

  def self.down
    remove_column :partners, :csv_file_name
  end
end
