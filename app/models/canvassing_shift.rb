class CanvassingShift < ActiveRecord::Base
  has_many :canvassing_shift_registrants, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :registrants, through: :canvassing_shift_registrants


  has_many :canvassing_shift_grommet_requests, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :grommet_requests, through: :canvassing_shift_grommet_requests


  validates_presence_of :shift_external_id

  after_save :check_submit_to_blocks

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
  
  def is_ready_to_submit?
    self.clock_in_datetime && self.clock_out_datetime
  end
  
  def set_attribute_from_data(attribute_name, data, data_attribute=nil)
    data_attribute ||= attribute_name
    #only update if not nil
    self.send("#{attribute_name}=", data[data_attribute]) if !data[data_attribute].blank?
  end  

  def check_submit_to_blocks
    if !submitted_to_blocks? && is_ready_to_submit?
      self.delay.submit_to_blocks
    end
  end

  def submit_to_blocks
    if !submitted_to_blocks? && is_ready_to_submit?
      service = BlocksService.new
      forms = service.upload_canvassing_shift(self)
      self.update_attributes(submitted_to_blocks: true)
      forms.each_with_index do |form_result, i|
        reg_req = registrations_or_requests[i]
        # Make sure form_result maps to reg_req
        if form_matches_request(form_result, reg_req)
          registrant_id = reg_req.is_a?(Registrant) ? reg_req.uid : nil
          grommet_request_id = reg_req.is_a?(Registrant) ? reg_req.state_ovr_data["grommet_request_id"] : reg_req.id
          GrommetRequestDisposition.create!(blocks_form_id: form_id, registrant_id: registrant_id, grommet_request_id: grommet_request_id)
        end
      end
    end
  end
  
  def form_martches_request(form_result, r)
    built_form = if r.is_a?(Registrant)
      BlocksService.form_from_registrant(r)
    elsif r.is_a?(GrommetRequest)
      BlocksService.form_from_grommet_request(r) 
    end
    
    return true if form_result["first_name"]==built_form[:first_name] && form_result["last_name"]==built_form[:last_name] && form_result["date_of_birth"] == built_form[:date_of_birth]
    
    raise "NO MATCH"
    
    return false
  end
  
  def registrations_or_requests
    @regs ||= nil
    if !@regs
      @regs = []
      registrant_grommet_ids = []
      self.registrants.each do |r| 
        registrant_grommet_ids << r.state_ovr_data["grommet_request_id"]
        @regs << r
      end
      self.grommet_requests.each do |req|
      unless registrant_grommet_ids.include?(req.id)
        @regs << req
      end
    end
    return @regs
  end
  
  
end
