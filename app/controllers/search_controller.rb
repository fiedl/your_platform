class SearchController < ApplicationController

  # https://github.com/ryanb/cancan/wiki/Ensure-Authorization
  skip_authorization_check

  def index
    query_string = params[ :query ]
    if query_string.present?
      
      # log search query for metrics analysis
      #
      metric_logger.log_event({query: query_string}, type: :search)
      current_user.try(:update_last_seen_activity, "sucht gerade etwas", nil)

      # browse users, pages and groups
      #
      q = "%" + query_string.gsub( ' ', '%' ) + "%"
      @users = User.where("CONCAT(first_name, ' ', last_name) LIKE ?", q)
        .order('last_name', 'first_name')
      @pages = Page.where("title like ? OR content like ?", q, q)
        .order('title')
      @groups = Group.where( "name like ?", q )

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
      
      # eleminiate duplicate results
      #
      @users.uniq!
      @pages.uniq!
      @groups.uniq!

      # AUTHORIZATION
      #
      @users = filter_by_authorization(@users)
      @pages = filter_by_authorization(@pages)
      @groups = filter_by_authorization(@groups)

      @results = @users + @pages + @groups
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
      @results = nil if @results.count == 0

    end
    @navable = Page.find_intranet_root
    @title = "Suche: #{query_string}"

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
      @result = Page.where(title: query_string).limit(1).first
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

  private

  def filter_by_authorization( resources )
    resources.select do |resource|
      can? :read, resource
    end
  end

end
