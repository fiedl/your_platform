class Api::V1::PostsController < Api::V1::BaseController

  expose :parent_page, -> { Page.find params[:parent_page_id] if params[:parent_page_id].present? }
  expose :parent_event, -> { Event.find params[:parent_event_id] if params[:parent_event_id].present? }
  expose :parent, -> { parent_page || parent_event }
  expose :sent_via, -> { params[:sent_via] }

  def create
    raise 'no parent given' unless parent
    authorize! :create_post, parent

    new_post = Post.create! post_params.merge({author_user_id: current_user.id, sent_via: sent_via})
    parent.child_posts << new_post

    render json: new_post, status: :ok
  end

  expose :post

  def update
    authorize! :update, post
    raise "Post #{post.id} is not a draft and cannot be updated anymore" unless post.draft?

    post.update! post_params

    render json: {}, status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text)
  end

end