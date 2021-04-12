class AbrsController < ApplicationController
  CURRENT_STEP = 1
  
  include ApplicationHelper
  include AbrHelper
  include TwilioHelper
  
  layout "abr"
  before_filter :find_partner
  
  rescue_from Abr::AbandonedRecord do |exception|
    abr = exception.abr
    redirect_to abr_timeout_url(partner_locale_options(abr.partner_id, abr.locale, abr.tracking_source))
  end
  
  def new
    @current_step = 1
    @abr = Abr.new(
        partner_id: @partner_id, 
        votercheck: @votercheck,
        current_step: @current_step,
        tracking_source: @source,
        tracking_id: @tracking,
        email: @email,
        first_name: @first_name,
        last_name: @last_name,
        home_state: @home_state,
        zip: @zip,
    )
    set_up_locale
    render "show"
  end
  
  def show
    @current_step = 1
    find_abr
  end
  
  def create
    @current_step = 1
    @abr = Abr.new(abr_params)
    set_up_locale
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
    find_abr(:state_online_redirect)
    @abr.update_attributes(:finish_with_state=>true)
    render :html => "<html><body><script>parent.location.href='#{@abr.home_state_oabr_url}';</script></body></html>".html_safe    
  end
  
  def update
    @abr = Abr.find_by_uid(params[:id])
    set_up_locale
    @current_step = begin params[:current_step].to_i rescue 1 end
    if !params[:abr_state_online_abr].nil? && @abr.eligible_for_oabr?
      redirect_to state_online_redirect_abr_path(@abr)
    else
      @abr.attributes = abr_params
      if continue_on_device_advance == :continued_on_device
        perform_current_step
      else
        @abr.current_step = @current_step + 1
        @abr.set_max_step(@current_step)      
        if @abr.save
          perform_next_step
        else
          perform_current_step
        end
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
      unless @abr.has_pdf_template?
        @abr.dead_end!
      end
      render step_3_view(@abr)      
    else
      redirect_to not_registered_abr_path(@abr)
    end
  end
  
  def preparing
    @current_step = 4
    find_abr(:preparing)
    if @abr.deliver_to_elections_office_via_email?
      redirect_to finish_abr_path(@abr)
    else
      @attempt = (params[:cno] || 1).to_i
      @refresh_location = @attempt >= 10 ? finish_abr_path(@abr) : preparing_abr_path(@abr, :cno=>@attempt+1)
    end
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
    attrs = [:first_name, :middle_name, :last_name, :name_suffix, :email, :street_name, :street_number, :unit, :city, :zip, :registration_county, :date_of_birth_month, :date_of_birth_day, :date_of_birth_year, :votercheck, :phone, :phone_type, :opt_in_email, :opt_in_sms, :partner_opt_in_email, :partner_opt_in_sms, :tracking_id, :tracking_source]
    if @abr
      attrs += @abr.permitted_attrs
      attrs += @abr.allowed_signature_attrs
    end
    params.require(:abr).permit(*attrs)
  end
  
  def find_abr(special_case = nil)
    @abr = Abr.find_by_param!(params[:id])
    set_up_locale
    # This may return false if validations don't work for being on this step.  Should we redirect backwards?
    raise ActiveRecord::RecordNotFound if @abr.complete? && special_case.nil?
    @abr.update_attributes(current_step: @current_step) if @current_step
    @abr_finish_iframe_url = @abr.finish_iframe_url
    
    @partner = @abr&.partner
    @partner_id = @partner&.id
    @old_wl = @partner && @partner.whitelabeled? && @partner.any_css_present? && !@partner.partner3_css_present?
    if @abr.finish_with_state? && special_case != :tell_friend && special_case != :finish
      @abr.update_attributes(:finish_with_state=>false)
    end
    
  end
  
  def perform_current_step
    @partner = @abr&.partner
    @partner_id = @partner&.id
    @old_wl = @partner && @partner.whitelabeled? && @partner.any_css_present? && !@partner.partner3_css_present?
    
    if @current_step == 1
      render :show
    elsif @current_step == 2
      render step_2_view(@abr)
    elsif @current_step == 3
      render step_3_view(@abr)
    end
  end


  def continue_on_device_advance
    # Set flash message?
    # Actually send the message
    if params.has_key?(:email_continue_on_device) 
      if @abr.email_address_for_continue_on_device =~ Authlogic::Regex::EMAIL
        AbrNotifier.continue_on_device(@abr, @abr.signature_capture_url).deliver_now
        flash[:success] = I18n.t('txt.signature_capture.abr.email_sent', email: @abr.email_address_for_continue_on_device)
        @abr.save(validate: false) # Make sure data persists even if not valid
      else
        @abr.errors.add(:email_address_for_continue_on_device, :format)
      end
      return :continued_on_device
    elsif params.has_key?(:sms_continue_on_device)
      if @abr.sms_number =~ /\A\d{10}\z/ #sms number has all non-digits removed
        begin
          twilio_client.messages.create(
            :from => "+1#{twilio_phone_number}",
            :to => @abr.sms_number,
            :body => I18n.t('txt.signature_capture.abr.sms_body', signature_capture_url: @abr.signature_capture_url)
          )
          flash[:success] = I18n.t('txt.signature_capture.abr.sms_sent', phone: @abr.sms_number_for_continue_on_device)
          @abr.save(validate: false) # Make sure data persists even if not valid
          
        rescue Twilio::REST::RequestError
          @abr.errors.add(:sms_number_for_continue_on_device, :format)
        end
      else
        #controller.flash[:warning] = I18n.t('states.custom.pa.signature_capture.sms_sent', phone: self.sms_number)
        @abr.errors.add(:sms_number_for_continue_on_device, :format)
      end
      return :continued_on_device
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
    if File.exists?(File.join(Rails.root, 'app/views/abrs/', "#{potential_view}.html.haml"))
      # In all cases we consider this registrant done!
      @abr.dead_end!
      return potential_view
    else
      return 'step_2'
    end
  end
  
  def step_3_view(abr)
    potential_view = "step_3_#{abr.home_state_abbrev.to_s.downcase}"
    File.exists?(File.join(Rails.root, 'app/views/abrs/', "#{potential_view}.html.haml")) ? potential_view : "step_3"
  end

  def set_up_locale
    params[:locale] = nil if !I18n.available_locales.collect(&:to_s).include?(params[:locale].to_s)
    @locale = params[:locale] || (@abr ? @abr.locale : nil) || 'en'
    I18n.locale = @locale.to_sym
  end
  
end