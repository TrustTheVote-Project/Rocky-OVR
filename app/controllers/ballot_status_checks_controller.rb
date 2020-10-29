class BallotStatusChecksController < ApplicationController
  layout "lookup"
  before_filter :find_partner

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
  end
  
  def zip
    @bsc = BallotStatusCheck.new(zip: params[:zip], partner_id: params[:partner])
  end

  def create
    @bsc = BallotStatusCheck.new(bsc_params)
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
  end
end
