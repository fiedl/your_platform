# The display of a blog is handled by the PagesController and the Page-associated views.
# This controller is just for adding a blog post via AJAX.
#
class BlogPostsController < PagesController
  prepend_before_action :set_inheritance_instance_variable

  load_and_authorize_resource
  skip_authorize_resource only: [:create]

  respond_to :json, :js

  def show
    redirect_to page_url(id: params[:id])
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
    end
  end

  def update
    params[:blog_post] ||= {}
    params[:blog_post][:archived] ||= params[:archived]  # required for archivable.js.coffee to work properly.
    set_inheritance_instance_variable
    @blog_post.update_attributes params[ :blog_post ].select { |k,v| v.present? && (v != "—")}
    respond_with_bip(@blog_post)
  end

  private

  def set_inheritance_instance_variable
    @page = @blog_post
    @pages = @blog_posts
    params[:page] = params[:blog_post]
  end

end

