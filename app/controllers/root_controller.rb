class RootController < ApplicationController

  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_public_website_if_needed
  before_action :redirect_to_sign_in_if_needed, :find_and_authorize_page

  def index
    set_current_navable @page
    set_current_activity :looks_at_the_start_page, @page
    set_current_access :user
    set_current_access_text :the_content_of_the_start_page_is_personalized
    set_current_tab :news

    @pinned_objects = Event.flagged(:pinned) + Page.flagged(:pinned)

    @blog_posts = BlogPost
      .relevant_to(current_user)
      .visible_to(current_user)
      .order(published_at: :desc)
      .limit(5)
      .select { |blog_post| can? :read, blog_post }

    @posts = current_user.posts_for_me
      .reorder(created_at: :desc)
      .limit(5)

    @documents = current_user.documents_in_my_scope
      .order(created_at: :desc)
      .limit(10)
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
      if home_page = Page.find_by(domain: request.host)
        redirect_to home_page
      elsif Page.public_website_present? and cannot?(:read, Page.intranet_root)
        redirect_to public_root_path
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

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    authorize! :show, @page
  end

end
