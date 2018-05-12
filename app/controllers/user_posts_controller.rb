class UserPostsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :user
  expose :posts_by_author, -> {
    BlogPost.where(author_user_id: user.id)
  }
  expose :posts_by_host, -> {
    Page.find(Group.flagged(:hosts).includes(:links_as_child).where(dag_links: {ancestor_type: "Page"}).pluck('dag_links.ancestor_id'))
  }
  expose :posts_by_guest, -> {
Page.find(Group.flagged(:guests).includes(:links_as_child).where(dag_links: {ancestor_type: "Page"}).pluck('dag_links.ancestor_id'))
  }
  expose :posts, -> {
    BlogPost
      .where(id: posts_by_author.pluck(:id) + posts_by_host.pluck(:id) + posts_by_guest.pluck(:id))
      .visible_to(current_user)
      .order(published_at: 'desc')
      .select { |post| can? :read, post }
  }

  def index
    authorize! :read_public_bio, user

    set_current_title "Posts by #{user.title}"
  end

end