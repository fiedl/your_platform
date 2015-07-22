class SearchController < ApplicationController

  # https://github.com/ryanb/cancan/wiki/Ensure-Authorization
  skip_authorization_check

  def index
    query_string = params[ :query ]
    if query_string.present?
      
      # log search query for metrics analysis
      #
      metric_logger.log_event({query: query_string}, type: :search)

      # browse users, pages, groups and events
      #
      q = "%" + query_string.gsub( ' ', '%' ) + "%"
      @users = User.where("CONCAT(first_name, ' ', last_name) LIKE ?", q)
        .order('last_name', 'first_name')
      @pages = Page.where("title like ? OR content like ?", q, q)
        .order('title')
      @groups = Group.where( "name like ?", q )
      @events = Event.where("name like ?", q).order('start_at DESC')
      @posts = Post.where("subject like ? or text like ?", q, q)
      
      # Convert to arrays in order to be able to add results through
      # associations below.
      @users = @users.to_a
      @pages = @pages.to_a
      @groups = @groups.to_a
      @events = @events.to_a
      @posts = @posts.to_a
      
      # browse profile fields
      #
      profile_fields = ProfileField.where("value like ? or label like ?", q, q).collect do |profile_field|
        profile_field.parent || profile_field
      end.uniq
      profile_fields.each do |profile_field|
        if profile_field.profileable.kind_of? User
          @users << profile_field.profileable
        elsif profile_field.profileable.kind_of? Group
          @groups << profile_field.profileable
        end
      end
      
      # browse attachments
      #
      attachments = Attachment.where("title like ? or description like ?", q, q).where(parent_type: 'Page')
      @pages += attachments.collect { |attachment| attachment.parent }
      
      # browse comments
      #
      comments = Comment.where("text like ?", q)
      comments.each do |comment|
        @posts << comment.commentable if comment.commentable.kind_of? Post
      end
      
      # eleminiate duplicate results
      #
      @users = @users.uniq
      @pages = @pages.uniq
      @groups = @groups.uniq
      @events = @events.uniq
      @posts = @posts.uniq
      
      # AUTHORIZATION
      #
      @users = filter_by_authorization(@users)
      @pages = filter_by_authorization(@pages)
      @groups = filter_by_authorization(@groups)
      @events = filter_by_authorization(@events)
      @posts = filter_by_authorization(@posts)

      @results = @users + @pages + @groups + @events + @posts
      if @results.count == 1
        redirect_to @results.first
      end
      
      if @results.count < 100
        @large_map_address_fields = @results.collect do |result|
          result.profile_fields.where(type: "ProfileFieldTypes::Address") if result.respond_to? :profile_fields
        end.flatten - [nil]
      end

      @pages = nil if @pages.count == 0
      @users = nil if @users.count == 0
      @groups = nil if @groups.count == 0
      @events = nil if @events.count == 0
      @posts = nil if @posts.count == 0
      @results = nil if @results.count == 0

    end
    set_current_navable Page.find_intranet_root
    set_current_title "#{t(:search)}: #{query_string}"
    set_current_activity :is_searching_for_something
  end
  
  # This action results in a redirection to the search result
  # considered to be a lucky guess.
  #
  #     /search/guess?query=FooBar
  #     would redirect to the Page with the title "FooBar".
  #
  def lucky_guess
    query_string = params[:query]
    if query_string.present?
      @result = Event.where(name: query_string).limit(1).first
      @result ||= Page.where(title: query_string).limit(1).first
      @result ||= Group.where(name: query_string).limit(1).first
      @result ||= User.find_by_name(query_string)
      @result ||= User.find_by_title(query_string)
      if @result
        redirect_to @result if can? :read, @result
      else
        redirect_to :action => :index, query: query_string
      end
    else
      redirect_to :action => :index
    end
  end
  
  # This returns title and body of a preview field (quick search).
  #
  def preview
    @object = find_preview_object(params[:query])
    respond_to do |format|
      format.json do
        if @object
          preview_template = "search/preview_#{@object.class.name.underscore}" # e.g. preview_user
          render json: {
            :title => 'Suchergebnis',
            :body => render_to_string(partial: preview_template, locals: {query: params['query'], obj: @object}, formats: ['html'])
          }
        else
          head :no_content
        end
      end
    end
  end
  
  # This implements the OpenSearch standard in order to support browser search tools
  # to search the application directly.
  #
  # * https://developer.apple.com/library/iad/releasenotes/General/WhatsNewInSafari/Articles/Safari_8_0.html
  # * http://www.opensearch.org/Specifications/OpenSearch/1.1#OpenSearch_description_document
  # * http://en.wikipedia.org/wiki/OpenSearch
  # * http://snippets.aktagon.com/snippets/519-how-to-add-opensearch-to-your-rails-app
  #
  def opensearch
    # fixes Firefox "Firefox could not download the search plugin from:"
    response.headers["Content-Type"] = 'application/opensearchdescription+xml'
    render :layout => false, formats: [:xml]
  end

  private

  def filter_by_authorization( resources )
    resources.select do |resource|
      can? :read, resource
    end
  end
  
  def find_preview_object(query_string)
    object = nil
    if query_string.present?
      like_query_string = "%" + query_string.gsub( ' ', '%' ) + "%"
    
      # The order of these assignments determines the priority.
      #
      object = Corporation.where(token: query_string).limit(1).first
      object ||= User.where(last_name: query_string).limit(1).first
      object ||= Page.where("title like ?", like_query_string).limit(1).first
      object ||= Group.where("name like ?", like_query_string).limit(1).first
      object ||= User.where("CONCAT(first_name, ' ', last_name) LIKE ?", like_query_string).limit(1).first

      object = nil unless can? :read, object
    end
    return object
  end

end
