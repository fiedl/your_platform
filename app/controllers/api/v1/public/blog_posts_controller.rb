class Api::V1::Public::BlogPostsController < Api::V1::PublicController

  expose :tags, -> { params[:tags] }
  expose :blog_posts, -> {
    @blog_posts = current_home_page.descendant_pages.where(type: "BlogPost") if current_home_page
    @blog_posts ||= BlogPost.all
    @blog_posts = @blog_posts.tagged_with(tags) if tags
    @blog_posts = @blog_posts.visible_to(current_user)
    @blog_posts = @blog_posts.select { |blog_post| can? :read, blog_post }
    @blog_posts
  }

  api :GET, '/api/v1/public/blog_posts', "Lists all public blog posts."
  param :tags, Array, of: String, desc: "Only list blog posts tagged with all of the given tags."

  def index
    authorize! :index, BlogPost

    begin
      render json: blog_posts
    rescue => exception
      render json: {error: exception.to_s}, status: :bad_request
    end
  end
end