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
    @registrant.status = params[:step]
    if @registrant.valid?
      @registrant.status = next_step
      @registrant.save
      if @registrant.complete?
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
    @attempt = (params[:cno] || 1).to_i
    @refresh_location = pending_state_registrant_path(@registrant, :cno=>@attempt+1)
    if !@registrant.pa_submission_complete
      render and return
    else
      if @registrant.pa_transaction_id.blank? || @attempt >= 20
        # finish with PDF
        redirect_to registrant_step_5_url(@registrant.registrant)
      else
        @registrant.cleanup!
        redirect_to state_registarnt_finish_path(@registrant)
      end
    end
  end
  
  
  def current_state
    params[:step]
  end
  
  def current_step
    #@registrant.current_step
    @registrant.step_index(params[:step]) + 1
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
    @num_steps = @registrant.num_steps
    if !@registrant.use_state_flow?
      #TODO how to determine if current registrant is still valid?
      # Should we always be copying data to the original reg record?
    end
  end
  
end
