class CreateGrommetRequests < ActiveRecord::Migration
  def change
    create_table :grommet_requests do |t|

      t.timestamps
      t.text :request_params
      
    end
  end
end
