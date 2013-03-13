class BookmarksController < ApplicationController

  respond_to :json

  def show
    respond_with Bookmark.find( params[ :id ] )
  end

  def index
#    @stars = find_stars
    respond_with find_bookmarks
#    respond_to do |format|
#      format.json { respond_with @stars }
#      format.html
#    end
  end

  def create
    respond_with Bookmark.create( params[ :bookmark ] )
  end

  def destroy
    respond_with Bookmark.find( params[ :id ] ).destroy
  end

  private 

  def find_bookmarks
    user = User.find params[ :user_id ] if params[ :user_id ].present?
    Bookmark.find_all_by_user( user ) if user
  end

end
