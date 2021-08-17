class Admin::MfaSessionsController < Admin::BaseController
  before_action :set_capture_mfa
  skip_before_action :check_mfa
  layout "admin"

  def new
    # current_admin is ensured by base_controller authenticate method    
  end

  def create
    admin = current_admin # grab your currently logged in user
    if admin.google_authentic?(params[:mfa_code].to_s)
      AdminMfaSession.create(admin)
      redirect_back_or_default admin_partners_path
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
