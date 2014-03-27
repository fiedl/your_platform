# The display of a blog is handled by the PagesController and the Page-associated views.
# This controller is just for adding a blog post via AJAX.
#
class BlogPostsController < PagesController
  prepend_before_filter :set_inheritance_instance_variable
  load_and_authorize_resource
  respond_to :json, :js
  
  def show
    redirect_to page_url(id: params[:id])
  end

  def create
    params[:parent_id].present? || raise('A blog post requires a parent_id to identify the parent page.')
    can?(:manage, Page.find(params[:parent_id])) || raise('Not authorized to add blog post. Make sure to have rights on the parent page.')
    @blog_post || raise('No @blog_post created by cancan.')
    @blog_post.title = I18n.t(:new_blog_post)
    @blog_post.author = current_user
    @blog_post.content = "—"
    @blog_post.save!
    @blog_post.parent_pages << Page.find(params[:parent_id])
    @page = @blog_post
    respond_to do |format|
      format.js
    end
  end

  def update
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

