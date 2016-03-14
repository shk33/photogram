class CommentsController < ApplicationController
  before_action :set_post, only: [:index,:create, :destroy]
  before_action :set_comment, only: [:destroy]

  def index
    @comments = @post.comments.order("created_at ASC")

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user_id = current_user.id

    if @comment.save
      create_notification @post
      respond_to do |format|
        format.html { redirect_to :back }
        format.js 
      end
    else
      flash[:alert] = "Check the comment form, something went horribly wrong."
      render root_path
    end

  end

  def destroy
    if current_user.owns_comment? @comment
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to :back }
        format.js 
      end
    end
  end

  private
    def create_notification post
      return if post.user.id == current_user.id
      Notification.create(user_id: post.user.id,
        notified_by_id: current_user.id,
        post_id: post.id,
        notice_type: 'comment')
    end

    def comment_params
      params.require(:comment).permit(:content)
    end

    def set_post
      @post = Post.find params[:post_id]
    end

    def set_comment
      @comment = @post.comments.find params[:id]
    end
end
