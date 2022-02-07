class BallotStatusChecksController < ApplicationController
  layout "ballot_status_check"
  before_action :find_partner

  def new
    @bsc = BallotStatusCheck.new(
      partner_id: @partner_id, 
      tracking_source: @source,
      tracking_id: @tracking,
      email: @email,
      first_name: @first_name,
      last_name: @last_name,
      zip: @zip,
    )
    set_up_locale
  end
  
  def zip
    @bsc = BallotStatusCheck.new(zip: params[:zip], partner_id: params[:partner])
    set_up_locale
  end

  def create
    @bsc = BallotStatusCheck.new(bsc_params.to_h.merge(
      query_parameters: @query_parameters
    ))
    set_up_locale
    #@bsc.partner_id = @partner_id
    if @bsc.save
      redirect_to ballot_status_check_zip_path(zip: @bsc.zip, partner: @bsc.partner_id)      
    else
      render :new
    end
  end

  private
  def bsc_params
    params.require(:ballot_status_check).permit(:first_name, :last_name, :email, :zip, :phone, :partner_id,
      "tracking_source",
      "tracking_id",
      "opt_in_email",
      "opt_in_sms",
      "partner_opt_in_email",
      "partner_opt_in_sms")
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
    @zip = params[:zip]

    @query_parameters = params[:query_parameters] || (request && request.query_parameters.clone.transform_keys(&:to_s).except(*([
      "locale",
      "source",
      "tracking",
      "email",
      "first_name",
      "last_name",
      "zip",
      "partner",
    ] ))) || {}
  end

  def set_up_locale
    params[:locale] = nil if !I18n.available_locales.collect(&:to_s).include?(params[:locale].to_s)
    @locale = params[:locale] || (@bsc ? @bsc.locale : nil) || 'en'
    I18n.locale = @locale.to_sym
  end
end
