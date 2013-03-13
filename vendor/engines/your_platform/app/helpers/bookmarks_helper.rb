module BookmarksHelper

  def star_tool( user, bookmarkable )
    if user and bookmarkable

      bookmark = Bookmark.find_by_user_and_bookmarkable( user, bookmarkable )
      content_tag 'star-tool', '', { 
        'bookmarkable-id' => bookmarkable.id, 'bookmarkable-type' => bookmarkable.class.name,
        'user-id' => user.id, 
        'bookmark' => bookmark.to_json
      }

    end
  end

  def bookmarked_objects_lis( user )
    if user
      render partial: "bookmarks/list", locals: { user_id: user.id, bookmarks: user.bookmarks }
    end
  end

end
