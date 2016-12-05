class FeedsController < ApplicationController

  def index
    authorize! :index, :feeds
    set_current_title t :feeds

    @feeds = Blog.all + ActsAsTaggableOn::Tag.all
    @feeds = @feeds.select { |feed| can? :read, feed }
  end

  def show
    @rss_root = Page.root
    @rss_items = case params[:id]
    when 'default'
      authorize! :read, :default_feed
      default_feed
    when 'personal'
      authorize! :read, :personal_feed
      personal_feed
    when 'public'
      authorize! :read, :public_feed
      public_feed
    end.select { |page| can?(:read, page) && page.not_empty? }
  end

  private

  def default_feed
    personal_feed || public_feed
  end

  def personal_feed
    current_user.try(:news_pages)
  end

  def public_feed
    BlogPost.all
  end

end