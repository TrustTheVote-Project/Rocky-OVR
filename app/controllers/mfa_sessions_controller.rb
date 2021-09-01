class MfaSessionsController < PartnerBase
  before_action :set_capture_mfa
  skip_before_action :check_mfa
  skip_before_action :require_partner
  #layout "admin"

  def new
    # current_user is ensured by base_controller authenticate method    
  end

  def create
    user = current_user # grab your currently logged in user
    if user.google_authentic?(params[:mfa_code].to_s)
      UserMfaSession.create(user)
      redirect_back_or_default partners_path
    else
      flash[:warning] = "The code you've entered is not correct"
      render :new
    end
  end

  private
  def set_capture_mfa
    @capture_mfa = true
  end

end
