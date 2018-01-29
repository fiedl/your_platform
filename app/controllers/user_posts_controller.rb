class UserPostsController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  #
  expose :user
  expose :posts, -> {
    BlogPost.where(author_user_id: user.id)
    .visible_to(current_user)
    .order(created_at: 'desc')
    .select { |post| can? :read, post }
  }

  def index
    authorize! :read_public_bio, user

    set_current_title "Posts by #{user.title}"
  end

end