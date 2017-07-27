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
      @days_num = (params[:days_num] || 1).to_i
      load_news(@days_ago.days.ago..(@days_ago - @days_num).days.ago)
    end
    @view_setting = current_user.settings.root_index_view_setting || RootController.default_view_setting

    @hide_attachment_drop_fields = true
    render html: view_context.convert_to_content_box(render_partial('news/index'))
  end

  private

  def load_news(date_range, query = nil)
    # Load Pages directly
    @pages = current_user.news_pages.where(published_at: date_range)
    @pages = @pages.where('title like ?', '%' + query + '%') if query
    @pages = @pages.select { |page| not page.public? }
    @pages = @pages.select { |page| page.not_empty? && can?(:read, page) }

    # Load Posts directly
    @posts = current_user.posts_for_me.where(created_at: date_range)
    @posts = @posts.where('subject like ?', '%' + query + '%') if query
    @posts = @posts.includes(:attachments, :author, :group, :comments, :directly_mentioned_users)

    # Add Posts by mentions
    @comments_by_mentions = Comment.where(created_at: date_range).includes(:mentions).where(mentions: {whom_user_id: current_user.id})
    @posts_by_mentions = Post.where(created_at: date_range).includes(:mentions).where(mentions: {whom_user_id: current_user.id})
    @comments_by_mentions = @comments_by_mentions.where('text like ?', '%' + query + '%') if query
    @posts_by_mentions = @posts_by_mentions.where('subject like ?', '%' + query + '%') if query
    @posts_by_mentions = @posts_by_mentions.includes(:attachments, :author, :group, :comments, :directly_mentioned_users)
    @posts = @posts + @posts_by_mentions + Post.where(id: @comments_by_mentions.where(commentable_type: 'Post').pluck(:commentable_id))

    # Load Events
    @events = current_user.events.where(start_at: date_range)
    @events = @events.where('name like ?', '%' + query + '%') if query
    @events = @events.where(id: @events.select { |event| event.attachments.any? }.map(&:id))

    # Sort Objects
    @posts = (@posts).uniq.sort_by { |obj| obj.updated_at }.reverse
    @pages = (@pages).uniq.sort_by { |obj| obj.published_at }.reverse
    @events = @events.distinct.order('events.updated_at desc')
    @objects = @posts + @pages + @events

    # Group Objects by Date
    @objects_by_date = @objects.group_by do |obj|
      if obj.respond_to? :start_at
        obj.start_at.to_date
      else
        obj.updated_at.to_date
      end
    end
    #@posts_by_date = @posts.group_by { |obj| obj.updated_at.to_date }
    #@pages_by_date = @pages.group_by { |obj| obj.updated_at.to_date }
    #@events_by_date
  end

  def log_request
    # No request logging for polling news.
    # This would create an undesired peak in the graph.
    # The user does not click anything etc.
  end

end