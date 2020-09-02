class AddFinishWithStateToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :finish_with_state, :boolean, default: false
  end
end
