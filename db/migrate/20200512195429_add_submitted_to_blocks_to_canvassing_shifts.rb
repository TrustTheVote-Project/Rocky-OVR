class AddSubmittedToBlocksToCanvassingShifts < ActiveRecord::Migration
  def change
    add_column :canvassing_shifts, :submitted_to_blocks, :boolean, default: false
  end
end
