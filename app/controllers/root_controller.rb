class RootController < ApplicationController

  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_public_website_if_needed
  before_action :redirect_to_sign_in_if_needed

  expose :events, -> { current_user.upcoming_events.limit(5) }
  expose :blog_posts, -> { BlogPost.relevant_to(current_user).visible_to(current_user).order(published_at: :desc).limit(5).select { |blog_post| can? :read, blog_post } }
  expose :documents, -> { current_user.documents_in_my_scope.order(created_at: :desc).limit(5) }
  expose :birthday_users, -> { Birthday.users_ordered_by_upcoming_birthday limit: 4 }

  expose :posts, -> {
    current_user.posts.published
    .where("published_at is null or published_at > ?", 1.year.ago)
    .where("sent_at is null or sent_at > ?", 1.year.ago)
    .order(sticky: :asc, updated_at: :desc)
    .limit(10)
  }

  expose :drafted_post, -> { current_user.drafted_posts.where(sent_via: post_draft_via_key).order(created_at: :desc).first_or_create }
  expose :post_draft_via_key, -> { "root-index" }

  def index
    authorize! :index, :root

    set_current_access :user
    set_current_access_text :the_content_of_the_start_page_is_personalized
    set_current_tab :start
  end


private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end

  def redirect_to_public_website_if_needed
    if not @need_setup
      if home_page = Page.find_by(domain: [request.host, "www.#{request.host}", request.host.gsub('www.', '')])
        redirect_to home_page
      # elsif Page.public_website_present? and cannot?(:read, Page.intranet_root)
      #   redirect_to public_root_path
      end
    end
  end

  # If a public website exists, which is not just a redirection, then signed-out
  # users are shown the public website.
  #
  # If no public website exists, the users are shown sign-in form.
  #
  def redirect_to_sign_in_if_needed
    if not @need_setup and not current_user
      redirect_to sign_in_path
    end
  end

end
