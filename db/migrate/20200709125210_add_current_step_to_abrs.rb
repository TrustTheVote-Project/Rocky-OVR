class AddCurrentStepToAbrs < ActiveRecord::Migration[4.2]
  def change
    add_column :abrs, :current_step, :string, index: true
    add_column :abrs, :max_step, :string, index: true
  end
end
