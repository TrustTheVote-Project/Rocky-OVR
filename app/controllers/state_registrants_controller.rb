class StateRegistrantsController < RegistrationStep
  
  # layout "registration"
  # before_filter :find_partner
  before_filter :load_state_registrant
    
  def edit
    render "state_registrants/#{@registrant.home_state_abbrev.downcase}/#{current_state}"
  end
  
  def update
    @registrant.attributes = params[@registrant.class.table_name.singularize]
    @registrant.save
    if !@registrant.use_state_flow?
      redirect_to registrant_step_2_path(@registrant.registrant) and return
    end
    
    @registrant.status = params[:step]
    if @registrant.valid?
      @registrant.status = next_step
      @registrant.save
      if @registrant.complete? && params[:step]==@registrant.step_list[-2]
        @registrant.async_submit_to_online_reg_url
        redirect_to pending_state_registrant_path(@registrant.to_param)
      else
        redirect_to edit_state_registrant_path(@registrant.status, @registrant.to_param)
      end
    else
      render "state_registrants/#{@registrant.home_state_abbrev.downcase}/#{current_state}"
    end
  end
  
  def pending
    @refresh_location = pending_state_registrant_path(@registrant)
    if !@registrant.pa_submission_complete
      render "state_registrants/#{@registrant.home_state_abbrev.downcase}/pending" and return
    else
      if @registrant.pa_transaction_id.blank?
        # finish with PDF
        redirect_to registrant_step_5_url(@registrant.registrant)
      else
        redirect_to complete_state_registrant_path(@registrant)
      end
    end
  end
  
  def complete
    render "state_registrants/#{@registrant.home_state_abbrev.downcase}/complete"
    
  end
  
  
  def current_state
    params[:step]
  end
  
  def current_step
    #@registrant.current_step
    (@registrant.step_index(params[:step]) || @registrant.num_steps)  + 1
  end

  def next_step
    @registrant.next_step(current_state)
  end
  
  def prev_step
    @registrant.prev_step(current_state)
  end

  private
  def load_state_registrant
    old_registrant = Registrant.find_by_param!(params[:registrant_id])
    @registrant = old_registrant.state_registrant
    if !@registrant
      redirect_to registrant_step_2_path(old_registrant) and return
    else
      @num_steps = @registrant.num_steps
    end
    set_up_locale
  end
  
end
