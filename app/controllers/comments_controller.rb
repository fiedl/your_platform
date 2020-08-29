class CommentsController < ApplicationController

  before_action :find_secure_commentable, only: :create
  before_action :create_guest_user_from_form_data, only: [:create]

  def show
    @comment = Comment.find params[:id]
    authorize! :read, @comment

    redirect_to @comment.commentable
  end

  private

  def find_secure_commentable
    @commentable = Post.find params[:comment][:commentable_id] if params[:comment][:commentable_type] == 'Post'
    @commentable = Page.find params[:comment][:commentable_id] if params[:comment][:commentable_type] == 'Page'
    @commentable || raise(ActionController::BadRequest, 'commentable not found.')
  end

end