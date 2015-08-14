class NewsController < ApplicationController
  skip_authorization_check only: :index
  layout false
    
  def index
    authorize! :index, :news
    
    if params[:query].present?
      @query = params[:query]
      load_news(1.year.ago..1.day.from_now, @query)
    else
      @days_ago = (params[:days_ago] || 1).to_i
      load_news(@days_ago.days.ago..(@days_ago-1).days.ago)
    end
    
    @hide_attachment_drop_fields = true
    render html: view_context.convert_to_content_box(render_partial('news/index'))
  end
  
  private
  
  def load_news(date_range, query = nil)
    # Load Pages directly
    @pages = current_user.news_pages.where(updated_at: date_range)
    @pages = @pages.search(query) if query
    @pages = @pages.select do |page|
      can?(:read, page) and
      (page.attachments.count > 0 or (page.content && page.content.length > 5))
    end
    
    # Load Posts directly
    @posts = current_user.posts_for_me.where(created_at: date_range)
    @posts = @posts.search(query) if query
    @posts = @posts.includes(:attachments, :author, :group, :comments, :directly_mentioned_users)
    
    # Add Posts by mentions
    @comments_by_mentions = Comment.where(created_at: date_range).includes(:mentions).where(mentions: {whom_user_id: current_user.id})
    @posts_by_mentions = Post.where(created_at: date_range).includes(:mentions).where(mentions: {whom_user_id: current_user.id})
    @comments_by_mentions = @comments_by_mentions.search(query) if query
    @posts_by_mentions = @posts_by_mentions.search(query) if query
    @posts_by_mentions = @posts_by_mentions.includes(:attachments, :author, :group, :comments, :directly_mentioned_users)
    @posts = @posts + @posts_by_mentions + Post.where(id: @comments_by_mentions.where(commentable_type: 'Post').select(:commentable_id).to_a)
    
    # Load Events
    @events = current_user.events.where(start_at: date_range)
    @events = @events.search(query) if query
    
    ## # Sort Objects
    @posts = (@posts).uniq.sort_by { |obj| obj.updated_at }.reverse
    @pages = (@pages).uniq.sort_by { |obj| obj.updated_at }.reverse
    @events = @events.order(:updated_at).reverse_order.to_a.uniq
    
    @objects = @posts.to_a + @pages.to_a + @events.to_a

    # Group Objects by Date
    @objects_by_date = @objects.group_by { |obj| obj.updated_at.to_date }
  end
  
end