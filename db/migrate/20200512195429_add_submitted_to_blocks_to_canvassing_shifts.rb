class AddSubmittedToBlocksToCanvassingShifts < ActiveRecord::Migration[4.2]
  def change
    add_column :canvassing_shifts, :submitted_to_blocks, :boolean, default: false
  end
end
