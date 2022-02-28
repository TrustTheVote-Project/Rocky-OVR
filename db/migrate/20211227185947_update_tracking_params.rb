class UpdateTrackingParams < ActiveRecord::Migration[5.2]
  def change
    begin
      rename_table :registrant_tracking_params, :tracking_params
    rescue
    end
    # Default index name is too long, specify index: name: for a shorter one
    add_reference :tracking_params, :query_param_trackable, polymorphic: true, index: {name: 'index_tracking_params_on_polymorphic'}

    reversible do |dir|
      dir.up { TrackingParam.update_all("query_param_trackable_id = registrant_id, query_param_trackable_type='Registrant'") }
      dir.down { TrackingParam.update_all('registrant_id = query_param_trackable_id') }
    end
    
    remove_reference :tracking_params, :registrant, index: true, foreign_key: true
  end
end
