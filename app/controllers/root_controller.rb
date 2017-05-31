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

    @hide_attachment_drop_fields = true

    @view_setting = view_setting
    @new_post = current_user.posts.new
  end


private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end

  def redirect_to_public_website_if_needed
    if not @need_setup and Page.public_website_present? and cannot?(:read, Page.intranet_root)
      redirect_to public_root_path
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

  # The user may choose how to view the root page:
  #   - 'timeline'
  #   - 'social'
  #
  # Change via the `view_setting` GET parameter on `root#index`.
  #
  def view_setting
    if params[:view_setting]
      if params[:view_setting].present?
        current_user.settings.root_index_view_setting = params[:view_setting].to_s
      else
        current_user.settings.root_index_view_setting = nil
      end
    end
    return current_user.settings.root_index_view_setting || self.class.default_view_setting
  end

  def self.default_view_setting
    'social'
  end

end
