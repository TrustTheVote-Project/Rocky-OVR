class AddFinishWithStateToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :finish_with_state, :boolean, default: false
  end
end
