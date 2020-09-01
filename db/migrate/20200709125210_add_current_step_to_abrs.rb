class AddCurrentStepToAbrs < ActiveRecord::Migration
  def change
    add_column :abrs, :current_step, :string, index: true
    add_column :abrs, :max_step, :string, index: true
  end
end
