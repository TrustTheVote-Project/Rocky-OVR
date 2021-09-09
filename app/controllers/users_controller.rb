class UsersController < PartnerBase
  layout "partners"
  ### public access
  skip_before_action :require_partner

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.attributes = params.require(:user).permit(:name, :email, :phone)
    if !params[:user][:password].blank?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end
    if @user.save
      flash[:success] = "Successfully updated your profile!"      
      redirect_to edit_user_path
    else
      render action: :edit
    end
  end

end