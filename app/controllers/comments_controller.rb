class CommentsController < ApplicationController
  
  before_action :find_secure_commentable
  
  def create
    authorize! :create_comment_for, @commentable
    
    @comment = @commentable.comments.build(comment_params)
    @comment.author = current_user
    @comment.save!
    
    redirect_to :back, change: 'comments'
  end
  
  private
  
  def comment_params
    params.require(:comment).permit(:text)
  end
  
  def find_secure_commentable
    @commentable = Post.find params[:comment][:commentable_id] if params[:comment][:commentable_type] == 'Post'
  end
  
end