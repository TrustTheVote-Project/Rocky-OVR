class CanvassingShift < ActiveRecord::Base
  has_many :canvassing_shift_registrants, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :registrants, through: :canvassing_shift_registrants


  has_many :canvassing_shift_grommet_requests, foreign_key: :shift_external_id, primary_key: :shift_external_id
  has_many :grommet_requests, through: :canvassing_shift_grommet_requests


  validates_presence_of :shift_external_id

  attr_accessor :building_via_web

  validates_presence_of [:canvasser_first_name, :canvasser_last_name, :partner_id, :canvasser_phone, :canvasser_email, :shift_location], if: :building_via_web
  validates_format_of :canvasser_phone, :with => /[ [:punct:]]*\d{3}[ [:punct:]]*\d{3}[ [:punct:]]*\d{4}\D*/, if: :building_via_web, allow_blank: true
  validates_format_of :canvasser_email, :with => Authlogic::Regex::EMAIL, if: :building_via_web, allow_blank: true

  def validate_phone_present_if_opt_in_sms(reg)
    return true if reg.building_via_api_call?
    if (reg.opt_in_sms? || reg.partner_opt_in_sms?) && reg.phone.blank?
      reg.errors.add(:phone, :required_if_opt_in)
    end
  end



  after_save :check_submit_to_blocks

  def self.location_options(partner)
    b = BlocksService.new
    locations = b.get_locations(partner)&.[]("locations")
    if locations && locations.any?
      puts locations
      return locations.map {|obj| [obj["name"], obj["id"]]}
    else
      return [
        ["Default Location", RockyConf.blocks_configuration.default_location_id],
      ]
    end
  end

  def locale
    :en
  end

  def new_registrant_url
    Rails.application.routes.url_helpers.new_registrant_url(shift_id: self.shift_external_id, host: RockyConf.default_url_host)
  end

  def canvasser_name
    [canvasser_first_name, canvasser_last_name].join(" ")
  end

  def canvasser_name=(name)
    name_parts = name.split(" ")
    self.canvasser_first_name = name_parts.shift
    self.canvasser_last_name = name_parts.join(" ") #Remaining parts
    canvasser_name
  end

  def set_attributes_from_data!(data)
    set_attribute_from_data(:shift_location, data, :canvass_location_id)
    %w(partner_id
      source_tracking_id
      partner_tracking_id
      geo_location
      open_tracking_id
      canvasser_name
      canvasser_first_name
      canvasser_last_name
      canvasser_phone
      canvasser_email
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

  def set_counts
    self.completed_registrations = registrants.complete.count
    self.abandoned_registrations = registrants.count - self.completed_registrations
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
      self.delay.submit_to_blocks # TODO: should delay for amount of abandoned time?
    end
  end

  def submit_to_blocks
    if !submitted_to_blocks? && is_ready_to_submit?
      service = BlocksService.new
      forms = service.upload_canvassing_shift(self)
      self.update_attributes(submitted_to_blocks: true)
      # TODO: don't create form dispositions until we can confirm an ID match
      # forms.each_with_index do |form_result, i|
      #   reg_req = registrations_or_requests[i]
      #   # Make sure form_result maps to reg_req
      #   if form_matches_request(form_result, reg_req)
      #     form_id = form_result["id"]
      #     registrant_id = reg_req.is_a?(Registrant) ? reg_req.uid : nil
      #     grommet_request_id = reg_req.is_a?(Registrant) ? reg_req.state_ovr_data["grommet_request_id"] : reg_req.id
      #     BlocksFormDisposition.create!(blocks_form_id: form_id, registrant_id: registrant_id, grommet_request_id: grommet_request_id)
      #   end
      # end
    end
  end

  def form_matches_request(form_result, r)
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
      self.registrants.complete.each do |r|
        registrant_grommet_ids << r.state_ovr_data["grommet_request_id"]
        @regs << r
      end
      self.grommet_requests.each do |req|
        unless registrant_grommet_ids.include?(req.id)
          @regs << req
        end
      end
    end
    return @regs
  end

  def generate_shift_external_id
    self.shift_external_id = "web-" + Digest::SHA1.hexdigest( "#{Time.now.usec} -- #{rand(1000000)} -- #{canvasser_name} -- #{partner_id}" )
  end


end
