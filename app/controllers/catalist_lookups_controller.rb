class CatalistLookupsController < ApplicationController
  include ApplicationHelper
  
  layout "lookup"
  before_filter :find_partner
  
  def new
    @lookup = CatalistLookup.new(
      partner_id: @partner_id, 
      tracking_source: @source,
      tracking_id: @tracking,
      email: @email,
      first: @first_name,
      last: @last_name,
      state: @home_state,
      zip: @zip,
    )
  end
  
  def show
    find_lookup
  end
  
  def create
    @lookup = CatalistLookup.new(lookup_params)
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
    @abr.save!
    redirect_to step_2_abr_path(@abr)
  end

  def registration
    find_lookup
    @registrant = @lookup.to_registrant
    @registrant.save!
    redirect_to registrant_step_2_path(@registrant)
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
  end

end