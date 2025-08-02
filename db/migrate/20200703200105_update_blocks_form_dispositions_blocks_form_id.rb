class UpdateBlocksFormDispositionsBlocksFormId < ActiveRecord::Migration[4.2]
  def change
    change_column :blocks_form_dispositions, :blocks_form_id, :string
  end
end
