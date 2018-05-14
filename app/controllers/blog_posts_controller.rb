# The display of a blog is handled by the PagesController and the Page-associated views.
# This controller is just for adding a blog post via AJAX.
#
class BlogPostsController < PagesController
  prepend_before_action :set_inheritance_instance_variable

  respond_to :json, :js

  def show
    @blog_post ||= @page
    authorize! :read, @blog_post

    respond_to do |format|
      format.html do
        @blog = @blog_post.parent
        @tags = @blog_post.tags

        set_current_navable @blog_post
        set_current_title @blog_post.title
      end
      format.mp4 do
        # The play is counted via `PageAnalyticsMetricLogging`.
        redirect_to @blog_post.video_url
      end
    end
  end

  def create
    secure_parent.present? || raise(ActionController::ParameterMissing, 'A blog post requires a parent_id to identify the parent page.')
    authorize! :create_page_for, secure_parent

    @page = @blog_post = BlogPost.create title: I18n.t(:new_blog_post), author_user_id: current_user.id, content: "—"
    secure_parent << @blog_post

    set_current_navable @blog_post   # this is needed in the BoxHelper in order to show the edit button.
    @blog_entries = [@blog_post]     # this is needed in the BoxHelper in order to hide the attachment box.
    @this_is_a_new_blog_post = true  # in to make the header a link.
    respond_to do |format|
      format.js
      format.html do
        redirect_to @blog_post
      end
    end
  end

  private

  def blog_post_params
    params[:blog_post] = page_params
  end

  def set_inheritance_instance_variable
    @page = @blog_post
    @pages = @blog_posts
    params[:page] ||= params[:blog_post]
  end

end

