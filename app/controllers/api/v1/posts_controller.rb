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
  expose :parent_groups, -> { Group.where id: params[:parent_group_ids] if params[:parent_group_ids].present? }

  def update
    authorize! :update, post
    raise "Post #{post.id} is not a draft and cannot be updated anymore" unless post.draft?

    post.update! post_params if params[:post].present?
    assign_parent_groups if parent_groups

    render json: {}, status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text, :publish_on_public_website)
  end

  def assign_parent_groups
    parent_groups.each { |group| authorize! :create_post, group }
    post.parent_groups = parent_groups
  end

end