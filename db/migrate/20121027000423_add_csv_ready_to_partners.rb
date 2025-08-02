class AddCsvReadyToPartners < ActiveRecord::Migration[4.2]
  def self.up
    add_column :partners, :csv_ready, :boolean, :default=>false
  end

  def self.down
    remove_column :partners, :csv_ready
  end
end
