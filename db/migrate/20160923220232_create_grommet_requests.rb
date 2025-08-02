class CreateGrommetRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :grommet_requests do |t|

      t.timestamps
      t.text :request_params
      
    end
  end
end
