class PostDeliveriesController < ApplicationController
  layout false
  
  def index
    @post = Post.find(params[:post_id]) || raise('no post given')
    authorize! :read, @post
  end
  
end