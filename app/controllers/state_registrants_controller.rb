class StateRegistrantsController < RegistrationStep
  
  # layout "registration"
  # before_filter :find_partner
    
  def new
    old_registrant = Registrant.find_by_param!(params[:registrant_id])
    @registrant = old_registrant.state_registrant
    @num_steps = @registrant.num_steps
    render :edit
  end
  
  def current_step
    @registrant.current_step
  end
end
