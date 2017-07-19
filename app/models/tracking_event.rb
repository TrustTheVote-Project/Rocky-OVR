class TrackingEvent < ActiveRecord::Base
  # attr_accessible :title, :body
  
  serialize :geo_location, Hash
  serialize :tracking_data, Hash
  
  SETTABLE_ATTRIBUTES= %w(tracking_event_name source_tracking_id partner_tracking_id open_tracking_id geo_location)
  
  def self.create_from_data(data_hash)
    data = ActiveSupport::HashWithIndifferentAccess.new(data_hash)
    te = TrackingEvent.new
    SETTABLE_ATTRIBUTES.each do |c_name|
      if c_name == "geo_location" && !data[c_name].is_a?(Hash)
        # Skip it and just stick it in the open data
        next
      else
        te.send("#{c_name}=", data.delete(c_name))
      end
    end
    
    # Now just set remaining data into tracking_data
    te.tracking_data=data
    
    te.save!
    return te
  end
  
end
