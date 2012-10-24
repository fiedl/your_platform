class SearchController < ApplicationController
  def index
    query_string = params[ :query ]
    if not query_string.empty?

      q = "%" + query_string + "%"
      @users = User.where( "first_name like ? or last_name like ?", q, q )
        .order( :last_name, :first_name )
      @pages = Page.where( "title like ?", q )
        .order( :title )
      @groups = Group.where( "name like ?", q )

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
end
