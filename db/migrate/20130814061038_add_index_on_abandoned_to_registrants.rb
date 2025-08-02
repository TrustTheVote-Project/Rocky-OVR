class AddIndexOnAbandonedToRegistrants < ActiveRecord::Migration[4.2]
  def self.up
    add_index :registrants, :abandoned
  end

  def self.down
    remove_index :registrants, :abandoned
  end
end
