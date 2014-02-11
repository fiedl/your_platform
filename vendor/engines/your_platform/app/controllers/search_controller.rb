class SearchController < ApplicationController

  # https://github.com/ryanb/cancan/wiki/Ensure-Authorization
  skip_authorization_check

  def index
    query_string = params[ :query ]
    if not query_string.empty?
      
      # log search query for metrics analysis
      #
      metric_logger.log_event({query: query_string}, type: :search)

      # browse users, pages and groups
      #
      q = "%" + query_string.gsub( ' ', '%' ) + "%"
      @users = User.where( "first_name like ? or last_name like ?", q, q )
        .order( :last_name, :first_name )
      @pages = Page.where( "title like ?", q )
        .order( :title )
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

      @pages = nil if @pages.count == 0
      @users = nil if @users.count == 0
      @groups = nil if @groups.count == 0
      @results = nil if @results.count == 0

    end
    @navable = Page.find_intranet_root
    @title = "Suche: #{query_string}"

  end

  private

  def filter_by_authorization( resources )
    resources.select do |resource|
      can? :read, resource
    end
  end

end
