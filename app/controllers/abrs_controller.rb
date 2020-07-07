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
    render "show"
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
  
  def step_2
    @abr = Abr.find(params[:id])
  end
  
  def abr_params
    params.require(:abr).permit(:first_name, :middle_name, :last_name, :name_suffix, :email, :address, :city, :zip, :date_of_birth_month, :date_of_birth_day, :date_of_birth_year)
  end
end