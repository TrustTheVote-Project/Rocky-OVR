class CatalistLookupsController < ApplicationController
  include ApplicationHelper
  
  layout "lookup"
  before_action :find_partner
  
  def new
    @lookup = CatalistLookup.new(
      partner_id: @partner_id,
      locale: @locale,
      tracking_source: @source,
      tracking_id: @tracking,
      email: @email,
      first: @first_name,
      last: @last_name,
      state: @home_state,
      zip: @zip,
      phone_type: "mobile",
    )
    if @lookup.partner.primary?
      @lookup.opt_in_email = true
    else
      if @lookup.partner.rtv_email_opt_in?
        @lookup.opt_in_email = true
      end
      if @lookup.partner.partner_email_opt_in?
        @lookup.partner_opt_in_email = true
      end
    end
    set_up_locale
  end
  
  def show
    find_lookup
  end
  
  def create
    @lookup = CatalistLookup.new(lookup_params.to_h.merge(
      query_parameters: @query_parameters
    ))
    @lookup.phone_type = "mobile"
    set_up_locale
    @lookup.partner_id = @partner_id
    if @lookup.save
      @lookup.lookup!
      redirect_to catalist_lookup_path(@lookup)      
    else
      render :new
    end
  end
  def not_registered
    #should we prevent a user from going back?
    #@current_step = 5 #final
    find_abr(:not_registered)
  end
  
  def abr
    find_lookup
    @abr = @lookup.to_abr
    @abr.save(validate: false)
    @lookup.abr = @abr
    @lookup.save(validate: false)    
    if !@abr.valid?
      redirect_to step_2_abr_path(@abr)
    else
      redirect_to abr_path(@abr)
    end
  end

  def registration
    find_lookup
    @registrant = @lookup.to_registrant
    @registrant.save(validate: false)
    @lookup.registrant = @registrant
    @lookup.save(validate: false)

    if !@registrant.valid?
      redirect_to registrant_step_2_path(@registrant)
    else
      redirect_to registrant_path(@registrant)
    end
  end
  
  
  private
  def lookup_params
    attrs =    ["first",
               "last",
               "suffix",
               "address",
               "city",
               "state_id",
               "zip",
               "date_of_birth_month",
               "date_of_birth_day",
               "date_of_birth_year",
               "tracking_source",
               "tracking_id",
               "phone",
               "phone_type",
               "email",
               "opt_in_email",
               "opt_in_sms",
               "partner_opt_in_email",
               "partner_opt_in_sms",
              ]
    params.require(:catalist_lookup).permit(*attrs)
  end
  
  def find_lookup(special_case = nil)
    @lookup = CatalistLookup.find_by_param!(params[:id])
    set_up_locale
    if @lookup.partner
      @partner    = @lookup.partner
      @partner_id = @partner.id
    end
    # This may return false if validations don't work for being on this step.  Should we redirect backwards?
    # raise ActiveRecord::RecordNotFound if @abr.complete? && special_case.nil?
  end
  
  def find_partner
    @partner = Partner.find_by_id(params[:partner]) || Partner.find(Partner::DEFAULT_ID)
    @partner_id = @partner.id
    set_params
  end
  
  def set_params
    @locale = 'en'
    @source = params[:source]
    @tracking = params[:tracking]
    @email = params[:email]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @state_abbrev = params[:state_abbrev] || params[:state]
    @zip = params[:zip]
    @home_state = @state_abbrev.blank? ? nil : GeoState[@state_abbrev.to_s.upcase]
    @home_state ||= @zip ? GeoState.for_zip_code(@zip.strip) : nil

    @query_parameters = params[:query_parameters] || (request && request.query_parameters.clone.transform_keys(&:to_s).except(*([
      "locale",
      "source",
      "tracking",
      "email",
      "first_name",
      "last_name",
      "state_abbrev",
      "state",
      "zip",
      "partner",
    ] ))) || {}
  end

  def set_up_locale
    params[:locale] = nil if !I18n.available_locales.collect(&:to_s).include?(params[:locale].to_s)
    @locale = params[:locale] || (@lookup ? @lookup.locale : nil) || 'en'
    I18n.locale = @locale.to_sym
  end

end