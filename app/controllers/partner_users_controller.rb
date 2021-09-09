class PartnerUsersController < PartnerBase
  layout "partners"

  def index
    @users = @partner.users
  end

  def create
    @user = User.add_to_partner!(params[:email], @partner)
    redirect_to action: :index
  end

  def destroy
    @user = User.find(params[:id])
    @partner_user = PartnerUser.where(partner: @partner, user: @user).first
    if @partner_user && @partner_user.delete
      flash[:success] = "Removed #{@user.name} from this partner"
    else
      flash[:error] = "Error removing #{@user.name} from this partner"
    end
    redirect_to action: :index
  end

end