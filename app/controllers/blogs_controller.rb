class BlogsController < PagesController #ApplicationController

  def show
    @blog_root_page = @blog ||= @page
    @blog_posts = @blog.blog_entries.for_display

    set_current_navable @blog_root_page
    set_current_title @blog_root_page.title
  end

  def update
    params[:page] = params[:blog]
    @page = @blog
    super
  end

end