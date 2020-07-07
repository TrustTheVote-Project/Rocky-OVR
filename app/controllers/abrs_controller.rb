class AbrsController < ApplicationController
  CURRENT_STEP = 1
  
  include ApplicationHelper
  include AbrHelper
  
  layout "abr"
  before_filter :find_partner
  
  
  def new
    @abr = Abr.new(
        partner_id: @partner_id, 
        # tracking_source: @source,
        # tracking_id: @tracking,
        email: @email_address,
        first_name: @first_name,
        last_name: @last_name,
        home_state: @home_state,
        zip: @home_zip_code,
    )
    @current_step = 1
    render "show"
  end
  
  def show
    @current_step = 1
    @abr = Abr.find_by_uid(params[:id])
  end
  
  def create
    @abr = Abr.new(abr_params)
    @abr.partner_id = @partner_id
    if @abr.save
      redirect_to step_2_abr_path(@abr)
    else
      render :show
    end
  end
  
  def update
    @abr = Abr.find_by_uid(params[:id])
    @current_step = begin params[:current_step].to_i rescue 1 end
    if @abr.update_attributes(abr_params)
      perform_next_step
    else
      perform_current_step
    end
  end
  
  def step_2
    @current_step = 2
    @abr = Abr.find_by_uid(params[:id])
  end
  
  def abr_params
    params.require(:abr).permit(:first_name, :middle_name, :last_name, :name_suffix, :email, :address, :city, :zip, :date_of_birth_month, :date_of_birth_day, :date_of_birth_year)
  end
private
  def perform_current_step
    if @current_step == 1
      render :show
    elsif @current_step == 2
      render :step_2
    end
  end
  
  def perform_next_step
    if @current_step == 1
      redirect_to step_2_abr_path(@abr)
    elsif @current_step == 2
      render :step_2
    end
  end
  
end