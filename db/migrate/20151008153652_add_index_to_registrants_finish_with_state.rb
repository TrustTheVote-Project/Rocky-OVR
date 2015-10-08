class AddIndexToRegistrantsFinishWithState < ActiveRecord::Migration
  def change
    add_index :registrants, :finish_with_state
  end
end
