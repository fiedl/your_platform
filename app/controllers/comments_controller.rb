class CommentsController < ApplicationController

  before_action :find_secure_commentable, only: :create

  def create
    authorize! :create_comment_for, @commentable

    @comment = @commentable.comments.build(text: comment_params[:text])
    @comment.author = current_user
    @comment.save!

    Notification.create_from_comment(@comment)
    Mention.create_multiple_and_notify_instantly(current_user, @comment, @comment.text)

    respond_to do |format|
      # Render the comment and reset the comment form.
      # app/views/comments/create.js.coffee
      #
      format.js
    end
  end

  def show
    @comment = Comment.find params[:id]
    authorize! :read, @comment

    redirect_to @comment.commentable
  end

  private

  def comment_params
    params.require(:comment).permit(:text, :commentable_id, :commentable_type)
  end

  def find_secure_commentable
    @commentable = Post.find params[:comment][:commentable_id] if params[:comment][:commentable_type] == 'Post'
    @commentable = Page.find params[:comment][:commentable_id] if params[:comment][:commentable_type] == 'Page'
    @commentable || raise(ActionController::BadRequest, 'commentable not found.')
  end

end