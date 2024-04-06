class StateRegistrantsController < RegistrationStep
  
  # layout "registration"
  # before_action :find_partner
  before_action :load_state_registrant
  
  def edit
    set_up_locale
    @use_mobile_ui = determine_mobile_ui(@registrant)
    render "state_registrants/#{@registrant.home_state_abbrev.downcase}/#{current_state}#{@use_mobile_ui ? '_mobile' : ''}"
  end
  
  def update
    @registrant.attributes = state_registrant_attributes
    @registrant.status = params[:step] if @registrant.should_advance(params)
    @registrant.check_locale_change
    set_up_locale
    @registrant.save
    @registrant.check_valid_for_state_flow!
    if !@registrant.use_state_flow? || @registrant.skip_state_flow?
      go_to_paper and return
    end
    if !@registrant.eligible?
      @registrant.skip_state_flow!
      @registrant.cleanup! if @registrant
      redirect_to(registrant_ineligible_url(@registrant)) and return

    end
    if @registrant.should_advance(params) && @registrant.valid?
      @registrant.status = next_step 
      @registrant.save    
      if @registrant.complete? && params[:step]==@registrant.step_list[-2]
        @registrant.async_submit_to_online_reg_url
        redirect_to pending_state_registrant_path(@registrant.to_param, state: @registrant.home_state_abbrev.downcase)
      else
        #raise edit_state_registrant_path(@registrant.to_param, @registrant.status).to_s
        redirect_to edit_state_registrant_path(@registrant.to_param, @registrant.status)
      end
    else
      @registrant.custom_advance(self, params)
      @use_mobile_ui = determine_mobile_ui(@registrant)
      render "state_registrants/#{@registrant.home_state_abbrev.downcase}/#{current_state}#{@use_mobile_ui ? '_mobile' : ''}"
    end
  end
  
  def skip_state_flow
    @registrant.registrant.skip_state_flow!
    @registrant.registrant.skip_mail_with_esig!
    go_to_paper
  end
  
  def pending
    if !@old_registrant
      # Skip other processing and render pending w/out variables set
      @use_mobile_ui = determine_mobile_ui(@registrant)
      render "state_registrants/#{params[:state]}/pending" and return
    end
    @refresh_location = pending_state_registrant_path(@registrant, state: @registrant.home_state_abbrev.downcase)
    if @registrant.skip_state_flow?
      go_to_paper and return
    end
    if !@registrant.submitted?
      if @registrant.complete?
        @use_mobile_ui = determine_mobile_ui(@registrant)
        render "state_registrants/#{@registrant.home_state_abbrev.downcase}/pending" and return
      else
        redirect_to edit_state_registrant_path(@registrant.to_param, @registrant.status)
      end
    else
      if @registrant.state_transaction_id.blank?
        # finish with PDF
        @registrant.registrant.skip_state_flow!
        go_to_paper
      else
        redirect_to complete_state_registrant_path(@registrant)
      end
    end
  end
  
  def complete
    set_up_locale
    @use_mobile_ui = determine_mobile_ui(@registrant)
    @registrant_finish_iframe_url = @registrant.finish_iframe_url
    render "state_registrants/#{@registrant.home_state_abbrev.downcase}/complete"    
  end
  
  
  def current_state
    params[:step]
  end
  
  def current_step_name
    current_state.to_s
  end
  
  def current_step
    #@registrant.current_step
    (@registrant.step_index(params[:step]) || @registrant.num_steps)  + 1
  rescue
    1
  end

  def next_step
    @registrant.next_step(current_state)
  end
  
  def prev_step
    @registrant.prev_step(current_state)
  end

  private
  def state_registrant_attributes 
    params.require(@registrant.class.table_name.singularize).permit(
      @registrant.class.permitted_attributes
    )
  end

  def load_state_registrant
    begin
      @old_registrant = Registrant.find_by_param!(params[:registrant_id])
    rescue Registrant::AbandonedRecord => exception
      reg = exception.registrant
      redirect_to registrants_timeout_url(partner_locale_options(reg.partner.id, reg.locale, reg.tracking_source))
      return
    rescue 
      return
    end
    @registrant = @old_registrant.state_registrant
    if !@registrant
      go_to_paper and return
    else
      @num_steps = @registrant.num_steps
      if @registrant.partner
        @partner    = @registrant.partner
        @partner_id = @partner.id
        @question_1 = @registrant.question_1
        @question_2 = @registrant.question_2
      end

      # to help deteermine if someone is iframing and we need to not use mobile ui
      @iframe_param = @registrant.other_parameters.include?('iframe=true')
    end
    
  end
  
  def go_to_paper
    @registrant.cleanup! if @registrant #Make sure we don't keep IDs around
    redirect_to registrant_step_2_path(@old_registrant)
  end
  
end