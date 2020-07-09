class SearchController < ApplicationController

  # https://github.com/ryanb/cancan/wiki/Ensure-Authorization
  skip_authorization_check

  expose :query, -> { params[:query].to_s }
  expose :query_string_with_wildcards, -> { "%" + query.gsub(' ', '%') + "%" }
  expose :q, -> { query_string_with_wildcards }
  expose :users, -> {
    filter_by_authorization User.search(query) if query.length > 3
  }
  expose :documents, -> {
    filter_by_authorization current_user.documents_in_my_scope.where("title like ?", "%#{query}%").order(created_at: :desc) if query.length > 3
  }
  expose :pages, -> {
    filter_by_authorization Page.where("title like ? OR content like ?", q, q).order(published_at: :desc, title: :asc) if query.length > 3
  }
  expose :groups, -> {
    filter_by_authorization Group.search(query) if query.length > 3
  }
  expose :events, -> {
    filter_by_authorization Event.where("name like ?", q).order('start_at DESC') if query.length > 3
  }
  expose :posts, -> {
    filter_by_authorization Post.where("subject like ? or text like ?", q, q).order(sent_at: :desc, created_at: :desc) if query.length > 3
  }
  expose :results, -> { users.to_a + documents.to_a + pages.to_a + groups.to_a + events.to_a + posts.to_a }
  expose :category, -> { params[:category] || ('users' if users.present?) || ('documents' if documents.present?) || ('events' if events.present?) || ('pages' if pages.present?) || ('groups' if groups.present?) || ('posts' if posts.present?) }

  def index
    if results.count == 1 and not documents.count == 1
      redirect_to results.first
    end
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
      if @result && can?(:read, @result)
        redirect_to @result
      else
        redirect_to :action => :index, query: query_string
      end
    else
      redirect_to :action => :index
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

  def log_activity
    # Do not log searches.
  end

end
