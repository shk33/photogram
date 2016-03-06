class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user  = User.find_by user_name: params[:user_name]
    @posts = User.find_by(user_name: params[:user_name])
      .posts.order created_at: :desc
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update profile_params
      flash[:success] = 'Your profile has been updated.'
      redirect_to profile_path @user.user_name
    else
      @user.errors.full_messages
      flash[:error] = @user.errors.full_messages
      render :edit
    end
  end

  private
    def profile_params
      params.require(:user).permit(:avatar, :bio)
    end

end
