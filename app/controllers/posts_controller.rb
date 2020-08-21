class PostsController < ApplicationController

  expose :post

  def show
    authorize! :read, post

    set_current_tab :communication
    set_current_title post.title
  end

  def update
    authorize! :update, post
    raise "Cannot modify posts that have already been sent." if post.sent_at.present?

    post.update! post_params
    render json: {}, status: :ok
  end

  def destroy
    authorize! :destroy, post
    raise "Cannot destroy published or sent posts, only drafts." unless post.draft?
    post.destroy!
    render json: {}, status: :ok
  end


  expose :user, -> { User.find params[:user_id] if params[:user_id].present? }
  expose :group, -> { Group.find params[:group_id] if params[:group_id].present? }
  expose :parent, -> { group || user || current_user }

  expose :posts, -> {
    posts = parent.posts.published
    if not group
      posts = posts
        .where("published_at is null or published_at > ?", 1.year.ago)
        .where("sent_at is null or sent_at > ?", 1.year.ago)
    end
    posts = posts
      .order(sticky: :asc, updated_at: :desc)
      .limit(50)
  }

  expose :drafted_post, -> {
    current_user.drafted_posts.where(sent_via: post_draft_via_key).order(created_at: :desc).first_or_create do |post|
      post.parent_groups << group if group
    end
  }

  expose :post_draft_via_key, -> {
    if parent
      "posts-index-#{parent.class.name}-#{parent.id}"
    else
      "posts-index"
    end
  }

  expose :menu_groups, -> { current_user.groups.regular }

  def index
    raise 'no parent given' unless parent
    authorize! :index_posts, parent

    set_current_title "Posts"
    set_current_tab :communication
  end

  private

  def post_params
    params.require(:post).permit(:text, :published_at)
  end

end
