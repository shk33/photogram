class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user_id = current_user.id

    if @comment.save
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
    @comment.destroy
    flash[:success] = "Comment deleted :("
    redirect_to :back
  end

  private
    def comment_params
      params.require(:comment).permit(:content)
    end

    def set_post
      @post = Post.find params[:post_id]
    end

    def set_comment
      @comment = Comment.find params[:id]
    end
end
