class CanvassingShiftsController < ApplicationController
  CURRENT_STEP = 0

  include ApplicationHelper

  layout "registration"
  before_filter :find_canvassing_shift

  def show
    if !@canvassing_shift
      redirect_to action: :set_partner
    end
  end

  def set_partner
  end

  def new
    find_partner
    if !@partner
      flash[:message] = "Partner #{params[:partner]} not available for canvassing shifts"
      redirect_to action: :set_partner
    end

    @new_canvassing_shift = CanvassingShift.new
  end

  def create
    @new_canvassing_shift = CanvassingShift.new(cs_params)
    @new_canvassing_shift.partner_id = params[:partner_id]
    @partner = Partner.find_by_id(params[:partner_id])
    @new_canvassing_shift.source_tracking_id = params[:source_tracking_id]
    @new_canvassing_shift.partner_tracking_id = params[:partner_tracking_id]
    @new_canvassing_shift.open_tracking_id = params[:open_tracking_id]
    @new_canvassing_shift.device_id = "web-#{request.ip}" #User IP?
    @new_canvassing_shift.generate_shift_external_id
    @new_canvassing_shift.shift_location ||= RockyConf.blocks_configuration.default_location_id
    @new_canvassing_shift.clock_in_datetime = DateTime.now
    @new_canvassing_shift.building_via_web = true
    if @new_canvassing_shift.save
      # If existing shift, clock it out
      if @canvassing_shift
        @canvassing_shift.clock_out_datetime = DateTime.now
        @canvassing_shift.save!
      end
      session[:canvassing_shift_id] = @new_canvassing_shift.id
      redirect_to action: :show
    else
      render action: :new
    end

  end

  def end_shift
    if @canvassing_shift
      @canvassing_shift.clock_out_datetime = DateTime.now
      @canvassing_shift.set_counts
      @canvassing_shift.save!
      flash[:message] = "#{@canvassing_shift.canvasser_name} clocked out at #{l @canvassing_shift.clock_out_datetime&.in_time_zone("America/New_York"), format: :short}"
    end
    session[:canvassing_shift_id] = nil
    redirect_to action: :set_partner
  end


  def current_step
    self.class::CURRENT_STEP
  end
  hide_action :current_step


  private

  def cs_params
    params.require(:canvassing_shift).permit(:canvasser_first_name, :canvasser_last_name, :canvasser_phone, :canvasser_email, :shift_location)
  end

  def find_partner
    @partners = Partner.where(id: RockyConf.blocks_configuration.partners.keys.collect(&:to_s))
    @partner = @partners.where(id: params[:partner]).first
    set_params
  end

  def set_params
    @source_tracking = params[:source] #source_tracking_id
    @partner_tracking = params[:tracking] #partner_tracking_id
    @open_tracking = params[:open_tracking] #open_tracking_id
  end



end
