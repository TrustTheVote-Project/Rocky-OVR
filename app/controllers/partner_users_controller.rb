class PartnerUsersController < PartnerBase
  layout "partners"

  def index
    @users = @partner.users
  end

  def create
    @user = User.add_to_partner!(params[:email], @partner)
    if @user
      flash[:success] = "Added #{@user.email}"
    else
      flash[:warning] = "Error adding #{params[:email]} to this partner"
    end
    redirect_to action: :index
  end

  def destroy
    @user = User.find(params[:id])
    @partner_user = PartnerUser.where(partner: @partner, user: @user).first
    if @partner_user && @partner_user.delete
      flash[:success] = "Removed #{@user.email} from this partner"
    else
      flash[:warning] = "Error removing #{@user.email} from this partner"
    end
    redirect_to action: :index
  end

end