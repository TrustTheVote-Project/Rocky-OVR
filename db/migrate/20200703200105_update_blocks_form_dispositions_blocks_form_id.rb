class UpdateBlocksFormDispositionsBlocksFormId < ActiveRecord::Migration
  def change
    change_column :blocks_form_dispositions, :blocks_form_id, :string
  end
end
