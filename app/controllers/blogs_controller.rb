class BlogsController < PagesController #ApplicationController

  def show
    @blog_root_page = @blog ||= @page
    @blog_posts = @blog.blog_entries.visible_to(current_user)

    set_current_navable @blog_root_page
    set_current_title @blog_root_page.title
  end

  def update
    params[:page] ||= params[:blog]
    params[:blog] ||= params[:page]
    @page ||= @blog
    @blog ||= @page
    super
  end

end