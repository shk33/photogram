class PostsController < ApplicationController

  before_action :set_post, only:[:show, :edit, :update, :destroy, :like, :unlike]
  before_action :owned_post, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @posts = Post.of_followed_users(current_user.following).order(created_at: :desc).page params[:page]
    respond_to do |format|
      format.html
      format.js 
    end
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build post_params

    if @post.save
      flash[:success] = "Your post has been created!"
      redirect_to posts_path
    else
      flash.now[:alert] = "Your new post couldn't be created!. Please check the form."
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @post.update post_params
      flash[:success] = "Post updated."
      redirect_to posts_path
    else
      flash.now[:alert] = "Update failed. Please check the form."
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url
  end

  def like
    if @post.liked_by current_user
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  def unlike
    if @post.unliked_by current_user
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  private
    def post_params
      params.require(:post).permit(:image, :caption)
    end

    def set_post
     @post = Post.find params[:id]
    end

    def owned_post
      unless current_user.owns_post? @post
        flash[:alert] = "You does not have permissions to be there."
        redirect_to root_path
      end
    end

end
