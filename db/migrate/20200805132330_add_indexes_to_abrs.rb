class AddIndexesToAbrs < ActiveRecord::Migration
  def change
    add_index :abrs, :abandoned
    add_index :abrs, :dead_end
    add_index :abrs, :current_step
    add_index :abrs, [:abandoned, :dead_end, :current_step], name: :index_abrs_for_abandonment
    
  end
end
