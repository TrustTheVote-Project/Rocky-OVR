class CanvassingShift < ActiveRecord::Base
  has_many :canvassing_shift_registrants, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :registrants, through: :canvassing_shift_registrants


  has_many :canvassing_shift_grommet_requests, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :grommet_requests, through: :canvassing_shift_grommet_requests


  validates_presence_of :shift_external_id

  def set_attributes_from_data!(data)
    set_attribute_from_data(:shift_location, data, :canvass_location_id)
    %w(partner_id 
      source_tracking_id 
      partner_tracking_id
      geo_location
      open_tracking_id
      canvasser_name
      canvasser_phone
      clock_in_datetime
      clock_out_datetime
      device_id
      abandoned_registrations
      completed_registrations
    ).each do |attribute|
      set_attribute_from_data(attribute, data)
    end
    
    self.save!
    return self
  end
  
  def set_attribute_from_data(attribute_name, data, data_attribute=nil)
    data_attribute ||= attribute_name
    #only update if not nil
    self.send("#{attribute_name}=", data[data_attribute]) if !data[data_attribute].blank?
  end
  
  
end
