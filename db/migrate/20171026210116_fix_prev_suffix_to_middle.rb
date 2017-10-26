class FixPrevSuffixToMiddle < ActiveRecord::Migration
  def up
    add_column :state_registrants_pa_registrants, :previous_middle_name, :string
    remove_column :state_registrants_pa_registrants, :previous_suffix
  end

  def down
    remove_column :state_registrants_pa_registrants, :previous_middle_name
    add_column :state_registrants_pa_registrants, :previous_suffix, :string
  end
end
