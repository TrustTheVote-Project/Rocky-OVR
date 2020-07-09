class AbrsController < ApplicationController
  CURRENT_STEP = 1
  
  include ApplicationHelper
  include AbrHelper
  
  layout "abr"
  before_filter :find_partner
  
  
  def new
    @current_step = 1
    @abr = Abr.new(
        partner_id: @partner_id, 
        votercheck: @votercheck,
        current_step: @current_step,
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
  
  def show
    @current_step = 1
    find_abr
  end
  
  def create
    @current_step = 1
    @abr = Abr.new(abr_params)
    @abr.partner_id = @partner_id
    @abr.set_max_step(@current_step)    
    if @abr.save
      redirect_to step_2_abr_path(@abr)
    else
      render :show
    end
  end
  
  def update
    @abr = Abr.find_by_uid(params[:id])
    @current_step = begin params[:current_step].to_i rescue 1 end
    @abr.current_step = @current_step + 1
    @abr.set_max_step(@current_step)
    if @abr.update_attributes(abr_params)
      perform_next_step
    else
      perform_current_step
    end
  end
  
  def step_2
    @current_step = 2
    find_abr
    render step_2_view(@abr)
  end
  
  def step_3
    @current_step = 3
    find_abr
    render step_3_view(@abr)
  end
  
  def abr_params
    params.require(:abr).permit(:first_name, :middle_name, :last_name, :name_suffix, :email, :address, :city, :zip, :date_of_birth_month, :date_of_birth_day, :date_of_birth_year, :votercheck, :state_id_number, :phone, :phone_type, :add_to_permanent_early_voting_list,
    :opt_in_email,
    :opt_in_sms,
    :partner_opt_in_email,
    :partner_opt_in_sms,
    :has_mailing_address)
  end
  
  def not_registered
    @abr = Abr.find_by_uid(params[:id])
  end
  
  def registration
    find_abr
    @registrant = @abr.to_registrant
    @registrant.save!
    redirect_to registrant_step_2_path(@registrant)
  end
  
  private
  
  def find_abr
    @abr = Abr.find_by_uid(params[:id])
    # This may return false if validations don't work for being on this step.  Should we redirect backwards?
    @abr.update_attributes(current_step: @current_step)  
  end
  
  def perform_current_step
    if @current_step == 1
      render :show
    elsif @current_step == 2
      render step_2_view(@abr)
    elsif @current_step == 3
      render step_3_view(@abr)      
    end
  end
  
  def perform_next_step
    if @current_step == 1
      redirect_to step_2_abr_path(@abr)
    elsif @current_step == 2
      if @abr.can_continue?
        redirect_to step_3_abr_path(@abr)
      else
        redirect_to not_registered_abr_path(@abr)
      end
    elsif @current_step == 3
      render :step_3
    end
  end
  
  def step_2_view(abr)
    potential_view = "step_2_#{abr.home_state_abbrev.to_s.downcase}"
    File.exists?(File.join(Rails.root, 'app/views/abrs/', potential_view)) ? potential_view : "step_2"
  end
  
  def step_3_view(abr)
    :step_3
  end
  
end