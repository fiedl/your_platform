class PostsController < ApplicationController
  def index
    @group = Group.find(params[:group_id]) if params[:group_id].present?
    @posts = @group.posts.order('sent_at DESC') if @group
    @title = t :current_posts
    @navable = @group
  end

  def show
    @post = Post.find(params[:id])
    @title = @post.subject
    @navable = @post.group
  end
end
