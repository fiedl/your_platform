# The display of a blog is handled by the PagesController and the Page-associated views.
# This controller is just for adding a blog post via AJAX.
#
class BlogPostsController < PagesController
  
  load_and_authorize_resource
  before_filter :set_inheritance_instance_variable
  respond_to :js 

  def create
    params[:parent_id].present? || raise('A blog post requires a parent_id to identify the parent page.')
    can?(:manage, Page.find(params[:parent_id])) || raise('not authorized to add blog post. Make sure to have rights on the parent page.')
    @blog_post.parent_pages << Page.find(params[:parent_id])
    @blog_post.title = I18n.t(:new_blog_post)
    @blog_post.author = current_user
    @blog_post.content = "–"
    @blog_post.save
    respond_with @blog_post
  end
  
  private
  
  def set_inheritance_instance_variable
    @page = @blog_post
    @pages = @blog_posts
    params[:page] = params[:blog_post]
  end
  
end

