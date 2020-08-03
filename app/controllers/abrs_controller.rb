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
  
  def state_online
    find_abr
  end
  
  def state_online_redirect
    find_abr
    @abr.update_attributes(:finish_with_state=>true)
    render :html => "<html><body><script>parent.location.href='#{@abr.home_state_oabr_url}';</script></body></html>".html_safe    
  end
  
  def update
    @abr = Abr.find_by_uid(params[:id])
    @current_step = begin params[:current_step].to_i rescue 1 end
    if !params[:abr_state_online_abr].nil? && @abr.eligible_for_oabr?
      redirect_to state_online_redirect_abr_path(@abr)
    else
      @abr.current_step = @current_step + 1
      @abr.set_max_step(@current_step)      
      if @abr.update_attributes(abr_params)
        perform_next_step
      else
        perform_current_step
      end
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
    if @abr.can_continue?
      render step_3_view(@abr)      
    else
      redirect_to not_registered_abr_path(@abr)
    end
  end
  
  def preparing
    @current_step = 4
    find_abr(:preparing)
    @attempt = (params[:cno] || 1).to_i
    @refresh_location = @attempt >= 10 ? finish_abr_path(@abr) : preparing_abr_path(@abr, :cno=>@attempt+1)
  end
  
  def download
    find_abr(:download)    
    if !@abr.pdf_ready?
      redirect_to finish_abr_path(@abr, not_ready: true)
    else
      @pdf_url = @abr.download_pdf
    end    
  end

  def finish
    @current_step = 5 #final
    find_abr(:finish)
    @abr_finish_iframe_url = @abr.finish_iframe_url
    @pdf_ready = false
    if params[:reminders]
      @abr.update_attributes(:reminders_left => 0, final_reminder_delivered: true)
      @stop_reminders = true
    end
    if params[:share_only] 
      @share_only = true
    elsif !params[:not_ready] && !params[:reminders]
      @pdf_ready = @abr.pdf_ready?
    end
  end
  
  
  def not_registered
    #should we prevent a user from going back?
    #@current_step = 5 #final
    find_abr(:not_registered)
  end
  
  def registration
    find_abr
    @registrant = @abr.to_registrant
    @registrant.save!
    redirect_to registrant_step_2_path(@registrant)
  end
  
  
  private
  def abr_params
    attrs = [:first_name, :middle_name, :last_name, :name_suffix, :email, :street_name, :street_number, :city, :zip, :date_of_birth_month, :date_of_birth_day, :date_of_birth_year, :votercheck, :phone, :phone_type, :opt_in_email, :opt_in_sms, :partner_opt_in_email, :partner_opt_in_sms]
    if @abr
      attrs += @abr.permitted_attrs
    end
    params.require(:abr).permit(*attrs)
  end
  
  def find_abr(special_case = nil)
    @abr = Abr.find_by_param!(params[:id])
    # This may return false if validations don't work for being on this step.  Should we redirect backwards?
    raise ActiveRecord::RecordNotFound if @abr.complete? && special_case.nil?
    @abr.update_attributes(current_step: @current_step) if @current_step
    
    if @abr.finish_with_state? && special_case != :tell_friend && special_case != :finish
      @abr.update_attributes(:finish_with_state=>false)
    end
    
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
      if @abr.eligible_for_oabr?
        redirect_to state_online_abr_path(@abr)
      else
        redirect_to step_3_abr_path(@abr)        
      end
    elsif @current_step == 3
      @abr.complete_registration
      redirect_to preparing_abr_path(@abr)
    end
  end
  
  def step_2_view(abr)
    potential_view = "step_2_#{abr.home_state_abbrev.to_s.downcase}"
    File.exists?(File.join(Rails.root, 'app/views/abrs/', "#{potential_view}.html.haml")) ? potential_view : "step_2"
  end
  
  def step_3_view(abr)
    potential_view = "step_3_#{abr.home_state_abbrev.to_s.downcase}"
    File.exists?(File.join(Rails.root, 'app/views/abrs/', "#{potential_view}.html.haml")) ? potential_view : "step_3"
  end
  
end