# The display of a blog is handled by the PagesController and the Page-associated views.
# This controller is just for adding a blog post via AJAX.
#
class BlogPostsController < PagesController
  prepend_before_action :set_inheritance_instance_variable

  respond_to :json, :js

  def show
    @blog_post ||= @page
    authorize! :read, @blog_post

    set_current_navable @blog_post
  end

  def create
    secure_parent.present? || raise('A blog post requires a parent_id to identify the parent page.')
    authorize! :create_page_for, secure_parent

    @blog_post || raise('No @blog_post created by cancan.')
    @blog_post.title = I18n.t(:new_blog_post)
    @blog_post.author = current_user
    @blog_post.content = "—"
    @blog_post.save!
    @blog_post.parent_pages << secure_parent
    @page = @blog_post
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

  def update
    @blog_post ||= @page
    authorize! :update, @blog_post

    params[:blog_post] ||= {}
    params[:blog_post][:archived] ||= params[:archived]  # required for archivable.js.coffee to work properly.
    set_inheritance_instance_variable

    @blog_post.update_attributes(blog_post_params)
    respond_with_bip(@blog_post)
  end

  private

  def blog_post_params
    params[:blog_post].try(:permit, :content, :title, :teaser_text, :author, :tag_list, :teaser_image_url, :archived) || {}
  end

  def set_inheritance_instance_variable
    @page = @blog_post
    @pages = @blog_posts
    params[:page] = params[:blog_post]
  end

end

